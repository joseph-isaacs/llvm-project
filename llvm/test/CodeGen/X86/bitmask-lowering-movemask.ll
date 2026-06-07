; RUN: opt -S -passes=bitmask-lowering -mtriple=x86_64-- < %s | llc -mtriple=x86_64-- -mattr=+avx2 | FileCheck %s

; End-to-end check that the bitmask-lowering pass turns the vectorized
; compare->bitmask idiom into a movemask instruction.  Before the pass the
; backend keeps the literal `1 << b` scatter (vpsllvd / vpor / horizontal
; reduce); after it, the whole thing is a single compare + vmovmskps.

declare i8 @llvm.vector.reduce.or.v8i8(<8 x i8>)

define i8 @gt5_to_mask(<8 x i32> %v) {
; CHECK-LABEL: gt5_to_mask:
; CHECK:         vpcmpgtd
; CHECK-NEXT:    vmovmskps %ymm0, %eax
; CHECK-NOT:     vpsllvd
; CHECK-NOT:     vpor
; CHECK:         retq
  %c = icmp sgt <8 x i32> %v, splat (i32 5)
  %sel = select <8 x i1> %c, <8 x i8> <i8 1, i8 2, i8 4, i8 8, i8 16, i8 32, i8 64, i8 -128>, <8 x i8> zeroinitializer
  %r = call i8 @llvm.vector.reduce.or.v8i8(<8 x i8> %sel)
  ret i8 %r
}
