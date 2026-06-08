; RUN: opt -S -passes=vector-combine -mtriple=aarch64-- < %s | llc -mtriple=aarch64-- | FileCheck %s

; AArch64 has no movemask instruction, but `bitcast <N x i1> to iN` lowers to the
; standard NEON mask-and + horizontal-add reduction (bic/and + addp), which is
; still cheaper than the un-lowered select + OR-reduction.  Check that the pass
; fires here too and that no select/OR-reduce scatter remains.

declare i16 @llvm.vector.reduce.or.v16i16(<16 x i16>)

define i16 @u8_nz_to_mask(<16 x i8> %v) {
; CHECK-LABEL: u8_nz_to_mask:
; CHECK:         cmeq v0.16b, v0.16b, #0
; CHECK:         bic v0.16b, v{{[0-9]+}}.16b, v0.16b
; CHECK-COUNT-3: addp v0.16b, v0.16b, v0.16b
; CHECK:         umov w0, v0.h[0]
; CHECK:         ret
  %c = icmp ne <16 x i8> %v, zeroinitializer
  %s = select <16 x i1> %c, <16 x i16> <i16 1, i16 2, i16 4, i16 8, i16 16, i16 32, i16 64, i16 128, i16 256, i16 512, i16 1024, i16 2048, i16 4096, i16 8192, i16 16384, i16 -32768>, <16 x i16> zeroinitializer
  %r = call i16 @llvm.vector.reduce.or.v16i16(<16 x i16> %s)
  ret i16 %r
}
