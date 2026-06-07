//===- BitmaskLowering.cpp - Compare->bitmask idiom lowering --------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass recognizes the "compare -> bitmask" idiom (a.k.a. movemask /
// bit-pack) and lowers it to a single `bitcast <N x i1> to iN`.
//
// When source code packs a vector of booleans into the bits of a scalar
// integer:
//
//     word = 0;
//     for (b = 0; b < N; ++b)
//       word |= (pred[b] ? 1 : 0) << b;
//
// the SLP/loop vectorizer turns it into one of several equivalent shapes that
// all compute, for an `<N x i1>` mask %m:
//
//     reduce.or ( select %m, <i 1, 2, 4, ..., 2^(N-1)>, zeroinitializer )
//     reduce.or ( shl (zext %m), <i 0, 1, 2, ..., N-1> )
//     reduce.or ( and (sext %m), <i 1, 2, 4, ..., 2^(N-1)> )
//     reduce.or ( mul (zext %m), <i 1, 2, 4, ..., 2^(N-1)> )
//
// (and the reduce.add / reduce.xor variants, which are equivalent because the
// lane contributions occupy disjoint bits).
//
// On little-endian targets each of these is exactly `bitcast %m to iN`
// (zero-extended to the reduction's element type), which the backend lowers to
// a movemask instruction (x86: PMOVMSKB / MOVMSKPS / vptestmb+kmov).  LLVM has
// no general recognizer for this idiom today -- it only forms a movemask for
// the N==4 case via the SLP vectorizer (see llvm/llvm-project#121691) -- so the
// vectorized scalar code keeps the literal `1 << b` scatter and is several
// times slower than a hand-written movemask.
//
// The rewrite is guarded by the cost model so that it only fires where the
// `bitcast <N x i1> to iN` is cheaper than the select+reduce it replaces.  On
// x86 it collapses to a single movemask, a large win.  On AArch64 NEON there is
// no movemask instruction, but the bitcast lowers to the standard mask-and +
// horizontal-add reduction (and/bic + addv/addp), which is still cheaper than
// the un-lowered select + OR-reduction -- so the cost model lets it fire there
// too (a smaller win).  Targets where the i1-vector/integer bitcast is more
// expensive than the original (the cost model decides per target) are left
// alone.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Scalar/BitmaskLowering.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/IR/Intrinsics.h"
#include "llvm/IR/PatternMatch.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/Local.h"

using namespace llvm;
using namespace PatternMatch;

#define DEBUG_TYPE "bitmask-lowering"

STATISTIC(NumBitmaskLowered, "Number of compare->bitmask idioms lowered");

static cl::opt<bool> BitmaskLoweringForce(
    "bitmask-lowering-force", cl::init(false), cl::Hidden,
    cl::desc("Lower the compare->bitmask idiom regardless of the cost model "
             "(for testing)"));

/// Return true iff \p C is a fixed integer vector whose lane \p i equals
/// `1 << i` for all lanes -- i.e. the per-lane "this lane owns bit i" weights.
static bool isBitWeightVector(const Constant *C, unsigned N, unsigned EltBits) {
  for (unsigned I = 0; I != N; ++I) {
    auto *CI = dyn_cast_or_null<ConstantInt>(C->getAggregateElement(I));
    if (!CI)
      return false;
    // `1 << I` fits because the caller guarantees EltBits >= N > I.
    if (CI->getValue() != (APInt(EltBits, 1) << I))
      return false;
  }
  return true;
}

/// Return true iff \p C is a fixed integer vector whose lane \p i equals \p i
/// -- i.e. an ascending shift-amount ramp 0, 1, 2, ..., N-1.
static bool isLaneIndexRamp(const Constant *C, unsigned N, unsigned EltBits) {
  for (unsigned I = 0; I != N; ++I) {
    auto *CI = dyn_cast_or_null<ConstantInt>(C->getAggregateElement(I));
    if (!CI || CI->getValue() != APInt(EltBits, I))
      return false;
  }
  return true;
}

/// If \p V computes, for some `<N x i1>` mask %m, the per-lane value
/// `%m[i] ? (1 << i) : 0`, return %m.  Otherwise return nullptr.
static Value *matchBitWeightedMask(Value *V) {
  auto *VecTy = dyn_cast<FixedVectorType>(V->getType());
  if (!VecTy || !VecTy->getElementType()->isIntegerTy())
    return nullptr;
  unsigned N = VecTy->getNumElements();
  unsigned EltBits = VecTy->getElementType()->getIntegerBitWidth();
  // Lane i contributes bit i, so the widest weight `1 << (N-1)` must be
  // representable in the element type.
  if (EltBits < N || N < 2)
    return nullptr;

  auto IsI1Mask = [&](Value *M) -> Value * {
    auto *MTy = dyn_cast<FixedVectorType>(M->getType());
    if (MTy && MTy->getElementType()->isIntegerTy(1) &&
        MTy->getNumElements() == N)
      return M;
    return nullptr;
  };

  Value *M;
  Constant *C;

  // select %m, <1, 2, 4, ...>, zeroinitializer
  if (match(V, m_Select(m_Value(M), m_Constant(C), m_Zero())))
    if (Value *Mask = IsI1Mask(M))
      if (isBitWeightVector(C, N, EltBits))
        return Mask;

  // and (sext %m), <1, 2, 4, ...>
  if (match(V, m_c_And(m_SExt(m_Value(M)), m_Constant(C))))
    if (Value *Mask = IsI1Mask(M))
      if (isBitWeightVector(C, N, EltBits))
        return Mask;

  // mul (zext %m), <1, 2, 4, ...>
  if (match(V, m_c_Mul(m_ZExt(m_Value(M)), m_Constant(C))))
    if (Value *Mask = IsI1Mask(M))
      if (isBitWeightVector(C, N, EltBits))
        return Mask;

  // shl (zext %m), <0, 1, 2, ...>
  if (match(V, m_Shl(m_ZExt(m_Value(M)), m_Constant(C))))
    if (Value *Mask = IsI1Mask(M))
      if (isLaneIndexRamp(C, N, EltBits))
        return Mask;

  return nullptr;
}

/// Decide whether replacing the select+reduce by a bitcast is profitable on
/// this target.
static bool isProfitable(const TargetTransformInfo &TTI, FixedVectorType *VecTy,
                         Type *ResTy, Type *MaskIntTy) {
  if (BitmaskLoweringForce)
    return true;

  constexpr auto CostKind = TTI::TCK_RecipThroughput;
  auto *CondTy = VecTy->getWithNewType(
      Type::getInt1Ty(VecTy->getContext()));

  InstructionCost OldCost =
      TTI.getCmpSelInstrCost(Instruction::Select, VecTy, CondTy,
                             CmpInst::BAD_ICMP_PREDICATE, CostKind) +
      TTI.getArithmeticReductionCost(Instruction::Or, VecTy, std::nullopt,
                                     CostKind);

  InstructionCost NewCost = TTI.getCastInstrCost(
      Instruction::BitCast, MaskIntTy, CondTy, TTI::CastContextHint::None,
      CostKind);
  if (MaskIntTy != ResTy)
    NewCost += TTI.getCastInstrCost(Instruction::ZExt, ResTy, MaskIntTy,
                                    TTI::CastContextHint::None, CostKind);

  LLVM_DEBUG(dbgs() << "BitmaskLowering: OldCost=" << OldCost
                    << " NewCost=" << NewCost << "\n");
  return NewCost < OldCost;
}

/// Try to lower a single `vector.reduce.{or,add,xor}` call.
static bool tryLowerReduction(IntrinsicInst *Reduce,
                              const TargetTransformInfo &TTI,
                              const DataLayout &DL) {
  // `bitcast <N x i1> to iN` packs lane i into bit i only on little-endian
  // targets; on big-endian the bit order is reversed and the rewrite would be
  // wrong.
  if (!DL.isLittleEndian())
    return false;

  Value *Mask = matchBitWeightedMask(Reduce->getArgOperand(0));
  if (!Mask)
    return false;

  auto *VecTy = cast<FixedVectorType>(Reduce->getArgOperand(0)->getType());
  unsigned N = VecTy->getNumElements();
  Type *ResTy = Reduce->getType();
  Type *MaskIntTy = IntegerType::get(Reduce->getContext(), N);

  if (!isProfitable(TTI, VecTy, ResTy, MaskIntTy))
    return false;

  IRBuilder<> Builder(Reduce);
  // bitcast <N x i1> %m to iN, then widen to the reduction's element type.
  Value *Bits = Builder.CreateBitCast(Mask, MaskIntTy);
  Value *Res = MaskIntTy == ResTy ? Bits : Builder.CreateZExt(Bits, ResTy);
  if (auto *ResI = dyn_cast<Instruction>(Res))
    ResI->takeName(Reduce);

  Reduce->replaceAllUsesWith(Res);
  Value *OldOperand = Reduce->getArgOperand(0);
  Reduce->eraseFromParent();
  // The select/shl/and/mul that fed the reduction is now usually dead.
  RecursivelyDeleteTriviallyDeadInstructions(OldOperand);
  ++NumBitmaskLowered;
  LLVM_DEBUG(dbgs() << "BitmaskLowering: lowered movemask over " << N
                    << " lanes\n");
  return true;
}

static bool runImpl(Function &F, const TargetTransformInfo &TTI) {
  const DataLayout &DL = F.getDataLayout();
  SmallVector<IntrinsicInst *, 8> Candidates;
  for (Instruction &I : instructions(F)) {
    if (auto *II = dyn_cast<IntrinsicInst>(&I)) {
      switch (II->getIntrinsicID()) {
      case Intrinsic::vector_reduce_or:
      case Intrinsic::vector_reduce_add:
      case Intrinsic::vector_reduce_xor:
        Candidates.push_back(II);
        break;
      default:
        break;
      }
    }
  }

  bool Changed = false;
  for (IntrinsicInst *II : Candidates)
    Changed |= tryLowerReduction(II, TTI, DL);
  return Changed;
}

PreservedAnalyses BitmaskLoweringPass::run(Function &F,
                                           FunctionAnalysisManager &AM) {
  auto &TTI = AM.getResult<TargetIRAnalysis>(F);
  if (!runImpl(F, TTI))
    return PreservedAnalyses::all();

  PreservedAnalyses PA;
  PA.preserveSet<CFGAnalyses>();
  return PA;
}
