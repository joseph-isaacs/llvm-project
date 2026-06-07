//===- BitmaskLowering.h - Compare->bitmask idiom lowering ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass recognizes the "compare -> bitmask" (a.k.a. movemask / bit-pack)
// idiom and rewrites it into a single `bitcast <N x i1> to iN`, which the
// backend lowers to a movemask-style instruction (e.g. x86 PMOVMSKB / vptestmb
// + kmov).  See BitmaskLowering.cpp for the recognized patterns.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_SCALAR_BITMASKLOWERING_H
#define LLVM_TRANSFORMS_SCALAR_BITMASKLOWERING_H

#include "llvm/IR/PassManager.h"

namespace llvm {

class Function;

/// Lower the compare->bitmask ("movemask") idiom to `bitcast <N x i1> to iN`.
class BitmaskLoweringPass : public PassInfoMixin<BitmaskLoweringPass> {
public:
  LLVM_ABI PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};

} // end namespace llvm

#endif // LLVM_TRANSFORMS_SCALAR_BITMASKLOWERING_H
