; REQUIRES: x86-registered-target
; RUN: opt -passes=loop-vectorize -mtriple=x86_64-unknown-linux-gnu \
; RUN:     -mattr=+avx2 -force-vector-width=8 -force-vector-interleave=2 -S < %s \
; RUN:   | FileCheck %s --check-prefix=UF2
; RUN: opt -passes=loop-vectorize -mtriple=x86_64-unknown-linux-gnu \
; RUN:     -mattr=+avx2 -S < %s | FileCheck %s --check-prefix=AUTO

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; With interleaving, every unrolled part must be packed: each part's shift
; amount is the part-0 induction plus a uniform offset, and the parts are
; combined by the in-loop compute-reduction-result.
;
; UF2-LABEL: @bitpack_uf2(
; UF2:       vector.body:
; UF2:         bitcast <8 x i1> {{.*}} to i8
; UF2:         bitcast <8 x i1> {{.*}} to i8
; UF2-NOT:     call i64 @llvm.vector.reduce.or

; Without forced flags the bit-pack reduction is planned in-loop, so the i64
; accumulator does not cap the VF at 256/64 = 4 and VF=8 is selected.
;
; AUTO-LABEL: @bitpack_uf2(
; AUTO:         bitcast <8 x i1> {{.*}} to i8
define i64 @bitpack_uf2(ptr %base, i32 %k) {
entry:
  br label %loop
loop:
  %acc = phi i64 [ 0, %entry ], [ %or, %loop ]
  %j = phi i64 [ 0, %entry ], [ %j.next, %loop ]
  %p = getelementptr inbounds i32, ptr %base, i64 %j
  %v = load i32, ptr %p, align 4
  %c = icmp ugt i32 %v, %k
  %z = zext i1 %c to i64
  %s = shl i64 %z, %j
  %or = or i64 %s, %acc
  %j.next = add nuw nsw i64 %j, 1
  %ec = icmp eq i64 %j.next, 64
  br i1 %ec, label %exit, label %loop
exit:
  %r = phi i64 [ %or, %loop ]
  ret i64 %r
}
