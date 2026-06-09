//===- BitPackIdiom.cpp - rewrite vectorized bit-pack reductions ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Prototype for the bit-pack reduction rewrite that belongs in a VPlan
// recipe. The LoopVectorizer turns
//
//   for (i) word |= (p[i] != 0) << i;
//
// into a single-block vector loop accumulating
//
//   acc.k = or(acc.k, shl(zext(<W x i1> cmp), iv-vector))
//
// into <W x iE> accumulators that are or-combined and reduce.or'ed after the
// loop. The shift vectors are lane-consecutive (widened IV: consecutive ramp
// start, uniform splat steps), so each iteration contributes exactly
//
//   zext(bitcast <W x i1> cmp to iW) << (lane 0 of the shift vector)
//
// per accumulator. Rewrite the accumulators to scalars accordingly.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Vectorize/BitPackIdiom.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/VectorUtils.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Transforms/Utils/Local.h"

using namespace llvm;
using namespace llvm::PatternMatch;

#define DEBUG_TYPE "bitpack-idiom"

namespace {

struct PackedAccumulator {
  PHINode *AccPhi;         // <W x iE> accumulator phi, starts at zero.
  Instruction *BackedgeOr; // or(AccPhi, Shl); also the loop-exit value.
  Value *Mask;             // <W x i1>
  PHINode *AmtIV;          // underlying lane-consecutive vector IV
  APInt AmtOffset;         // constant offset of the shift vector off AmtIV
};

struct ConsecutiveIV {
  APInt Start0; // lane 0 of the start ramp
  APInt Step;   // uniform per-iteration step
};

/// Peel a chain of `add(X, splat(constant))` off \p V, accumulating the
/// constant offsets, and return the underlying value.
static Value *peelConstSplatAdds(Value *V, APInt &Offset) {
  unsigned Depth = 0;
  while (++Depth <= 8) {
    Value *A, *B;
    if (!match(V, m_Add(m_Value(A), m_Value(B))))
      return V;
    Value *Splat;
    if ((Splat = getSplatValue(B)))
      V = A;
    else if ((Splat = getSplatValue(A)))
      V = B;
    else
      return V;
    auto *CI = dyn_cast<ConstantInt>(Splat);
    if (!CI)
      return nullptr;
    Offset = Offset.zext(std::max(Offset.getBitWidth(),
                                  CI->getValue().getBitWidth())) +
             CI->getValue().zext(std::max(Offset.getBitWidth(),
                                          CI->getValue().getBitWidth()));
  }
  return nullptr;
}

/// If \p V is `IV-phi + constant-splat-chain` where the phi is a
/// lane-consecutive vector IV of \p Body (consecutive ramp start, uniform
/// constant splat steps), return the phi and fill \p Offset / \p IVInfo.
static PHINode *analyzeShiftVector(Value *V, BasicBlock *Body, APInt &Offset,
                                   ConsecutiveIV &IVInfo) {
  unsigned Bits = cast<FixedVectorType>(V->getType())->getScalarSizeInBits();
  Offset = APInt(Bits, 0);
  Value *Base = peelConstSplatAdds(V, Offset);
  auto *IV = dyn_cast_or_null<PHINode>(Base);
  if (!IV || IV->getParent() != Body || IV->getNumIncomingValues() != 2)
    return nullptr;

  Constant *Start = nullptr;
  Value *Next = nullptr;
  for (unsigned I = 0; I != 2; ++I) {
    if (IV->getIncomingBlock(I) == Body)
      Next = IV->getIncomingValue(I);
    else
      Start = dyn_cast<Constant>(IV->getIncomingValue(I));
  }
  if (!Start || !Next)
    return nullptr;

  // Start: consecutive ramp.
  auto *VT = cast<FixedVectorType>(IV->getType());
  auto *C0 = dyn_cast_or_null<ConstantInt>(Start->getAggregateElement(0u));
  if (!C0)
    return nullptr;
  for (unsigned I = 1, N = VT->getNumElements(); I != N; ++I) {
    auto *CI = dyn_cast_or_null<ConstantInt>(Start->getAggregateElement(I));
    if (!CI || CI->getValue() != C0->getValue() + I)
      return nullptr;
  }

  // Backedge: the phi plus constant splat adds.
  APInt Step(Bits, 0);
  if (peelConstSplatAdds(Next, Step) != IV)
    return nullptr;

  IVInfo = {C0->getValue(), Step};
  return IV;
}

/// Match \p V as the backedge `or` of a bit-pack accumulator in the
/// single-block self-loop \p Body.
static bool matchAccumulator(Value *V, BasicBlock *Body,
                             PackedAccumulator &Out) {
  auto *I = dyn_cast<Instruction>(V);
  if (!I || I->getParent() != Body)
    return false;
  Value *PhiV, *ShlV;
  if (!match(I, m_c_Or(m_Value(PhiV), m_Value(ShlV))))
    return false;
  if (!isa<PHINode>(PhiV))
    std::swap(PhiV, ShlV);
  auto *Phi = dyn_cast<PHINode>(PhiV);
  if (!Phi || Phi->getParent() != Body || Phi->getNumIncomingValues() != 2)
    return false;

  // Phi: starts at zero, fed by this or; used only by this or.
  Value *Init = nullptr;
  for (unsigned K = 0; K != 2; ++K)
    if (Phi->getIncomingBlock(K) != Body)
      Init = Phi->getIncomingValue(K);
    else if (Phi->getIncomingValue(K) != I)
      return false;
  if (!Init || !match(Init, m_Zero()) || !Phi->hasOneUse())
    return false;

  Value *Mask, *Amt;
  if (!match(ShlV, m_OneUse(m_Shl(m_OneUse(m_ZExt(m_Value(Mask))),
                                  m_Value(Amt)))))
    return false;
  auto *MTy = dyn_cast<FixedVectorType>(Mask->getType());
  if (!MTy || !MTy->getElementType()->isIntegerTy(1) ||
      MTy->getNumElements() >
          cast<FixedVectorType>(I->getType())->getScalarSizeInBits())
    return false;
  APInt Offset;
  ConsecutiveIV IVInfo;
  PHINode *IV = analyzeShiftVector(Amt, Body, Offset, IVInfo);
  if (!IV)
    return false;

  Out = {Phi, I, Mask, IV, Offset};
  return true;
}

static bool runImpl(Function &F) {
  bool Changed = false;
  SmallVector<IntrinsicInst *, 4> Reduces;
  for (Instruction &I : instructions(F))
    if (auto *II = dyn_cast<IntrinsicInst>(&I))
      if (II->getIntrinsicID() == Intrinsic::vector_reduce_or)
        Reduces.push_back(II);

  for (IntrinsicInst *R : Reduces) {
    // Decompose the reduce argument into an or-tree whose leaves are
    // accumulator backedge ors living in one single-block self-loop.
    SmallVector<Value *, 8> Worklist{R->getArgOperand(0)};
    SmallVector<PackedAccumulator, 8> Accs;
    SmallVector<Instruction *, 8> TreeOrs;
    BasicBlock *Body = nullptr;
    bool OK = true;
    while (!Worklist.empty() && OK) {
      Value *V = Worklist.pop_back_val();
      auto *VI = dyn_cast<Instruction>(V);
      if (!VI) {
        OK = false;
        break;
      }
      bool SelfLoop = is_contained(predecessors(VI->getParent()),
                                   VI->getParent());
      PackedAccumulator Acc;
      if (SelfLoop && matchAccumulator(VI, VI->getParent(), Acc)) {
        if (!Body)
          Body = VI->getParent();
        if (Body != VI->getParent() ||
            // Backedge or: used by the phi and exactly one tree edge.
            !Acc.BackedgeOr->hasNUses(2)) {
          OK = false;
          break;
        }
        Accs.push_back(Acc);
        continue;
      }
      Value *A, *B;
      if (!SelfLoop && match(VI, m_OneUse(m_Or(m_Value(A), m_Value(B))))) {
        TreeOrs.push_back(VI);
        Worklist.push_back(A);
        Worklist.push_back(B);
        continue;
      }
      OK = false;
    }
    if (!OK || Accs.empty() || !Body || R->getParent() == Body)
      continue;

    BasicBlock *Preheader = nullptr;
    for (BasicBlock *Pred : predecessors(Body))
      if (Pred != Body)
        Preheader = Pred;
    if (!Preheader)
      continue;

    // Rewrite each accumulator to a scalar. Share one scalar IV per
    // underlying vector IV (lane 0's value).
    Type *ResTy = R->getType();
    IRBuilder<> RB(R);
    SmallDenseMap<PHINode *, PHINode *, 4> ScalarIVs;
    Value *Total = nullptr;
    for (PackedAccumulator &Acc : Accs) {
      unsigned W =
          cast<FixedVectorType>(Acc.Mask->getType())->getNumElements();
      PHINode *&SIV = ScalarIVs[Acc.AmtIV];
      if (!SIV) {
        APInt Offset(64, 0);
        ConsecutiveIV IVInfo{APInt(), APInt()};
        analyzeShiftVector(Acc.AmtIV, Body, Offset, IVInfo);
        Type *IVTy = Acc.AmtIV->getType()->getScalarType();
        SIV = PHINode::Create(IVTy, 2, "bitpack.iv", Body->begin());
        IRBuilder<> TB(Body->getTerminator());
        Value *IVNext = TB.CreateAdd(
            SIV, ConstantInt::get(IVTy, IVInfo.Step), "bitpack.iv.next");
        SIV->addIncoming(ConstantInt::get(IVTy, IVInfo.Start0), Preheader);
        SIV->addIncoming(IVNext, Body);
      }
      PHINode *SPhi =
          PHINode::Create(ResTy, 2, "bitpack.acc", Body->begin());
      IRBuilder<> IB(Acc.BackedgeOr);
      Value *Base = SIV;
      if (!Acc.AmtOffset.isZero())
        Base = IB.CreateAdd(
            Base, ConstantInt::get(Base->getType(),
                                   Acc.AmtOffset.zextOrTrunc(
                                       Base->getType()->getIntegerBitWidth())));
      if (Base->getType() != ResTy)
        Base = IB.CreateZExtOrTrunc(Base, ResTy);
      Value *Bits = IB.CreateZExt(
          IB.CreateBitCast(Acc.Mask, IB.getIntNTy(W)), ResTy, "bitpack.bits");
      Value *Sh = IB.CreateShl(Bits, Base);
      Value *NewAcc = IB.CreateOr(SPhi, Sh, "bitpack.next");
      SPhi->addIncoming(Constant::getNullValue(ResTy), Preheader);
      SPhi->addIncoming(NewAcc, Body);
      Total = Total ? RB.CreateOr(Total, NewAcc) : NewAcc;
    }
    R->replaceAllUsesWith(Total);
    R->eraseFromParent();
    for (Instruction *O : TreeOrs)
      if (O->use_empty())
        O->eraseFromParent();
    for (PackedAccumulator &Acc : Accs) {
      PHINode *P = Acc.AccPhi;
      Instruction *BO = Acc.BackedgeOr;
      P->replaceAllUsesWith(PoisonValue::get(P->getType()));
      BO->replaceAllUsesWith(PoisonValue::get(BO->getType()));
      P->eraseFromParent();
      RecursivelyDeleteTriviallyDeadInstructions(BO);
    }
    Changed = true;
  }
  return Changed;
}

} // namespace

PreservedAnalyses BitPackIdiomPass::run(Function &F,
                                        FunctionAnalysisManager &AM) {
  if (!runImpl(F))
    return PreservedAnalyses::all();
  PreservedAnalyses PA;
  PA.preserveSet<CFGAnalyses>();
  return PA;
}
