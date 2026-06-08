; RUN: opt -S -passes=vector-combine -mtriple=x86_64-- < %s | FileCheck %s --check-prefixes=X86
; RUN: opt -S -passes=vector-combine -data-layout="E-m:e-i64:64-n32:64" < %s | FileCheck %s --check-prefixes=BE

declare i8 @llvm.vector.reduce.or.v8i8(<8 x i8>)

; On x86 the bitcast is a cheap movemask, so the cost model fires.
; On a big-endian target the bit order of `bitcast <N x i1> to iN` is reversed,
; so the rewrite is unsound and is unconditionally suppressed.
define i8 @endianness_guard(<8 x i1> %m) {
; X86-LABEL: @endianness_guard(
; X86-NEXT:    [[R:%.*]] = bitcast <8 x i1> [[M:%.*]] to i8
; X86-NEXT:    ret i8 [[R]]
;
; BE-LABEL: @endianness_guard(
; BE-NEXT:    [[SEL:%.*]] = select <8 x i1> [[M:%.*]], <8 x i8> <i8 1, i8 2, i8 4, i8 8, i8 16, i8 32, i8 64, i8 -128>, <8 x i8> zeroinitializer
; BE-NEXT:    [[R:%.*]] = call i8 @llvm.vector.reduce.or.v8i8(<8 x i8> [[SEL]])
; BE-NEXT:    ret i8 [[R]]
;
  %sel = select <8 x i1> %m, <8 x i8> <i8 1, i8 2, i8 4, i8 8, i8 16, i8 32, i8 64, i8 -128>, <8 x i8> zeroinitializer
  %r = call i8 @llvm.vector.reduce.or.v8i8(<8 x i8> %sel)
  ret i8 %r
}
