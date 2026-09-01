; REQUIRES: x86-registered-target
; RUN: opt -passes=loop-vectorize -mtriple=x86_64-unknown-linux-gnu \
; RUN:     -mattr=+avx2 -force-vector-width=8 -force-vector-interleave=1 -S < %s \
; RUN:   | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; The positional bit-pack idiom: an or-reduction whose per-lane contribution is
; (cmp << lane) becomes a scalar accumulation of movemask chunks.
define i64 @bitpack_ugt(ptr %base, i32 %k) {
; CHECK-LABEL: @bitpack_ugt(
; CHECK:       vector.body:
; CHECK:         %[[C:.*]] = icmp ugt <8 x i32>
; CHECK:         %[[P:.*]] = bitcast <8 x i1> %[[C]] to i8
; CHECK:         zext i8 %[[P]] to i64
; CHECK-NOT:     call i64 @llvm.vector.reduce.or
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

; Any compare predicate works; the mask is what matters, not the comparison.
define i64 @bitpack_slt(ptr %base, i32 %k) {
; CHECK-LABEL: @bitpack_slt(
; CHECK:       vector.body:
; CHECK:         %[[C:.*]] = icmp slt <8 x i32>
; CHECK:         bitcast <8 x i1> %[[C]] to i8
entry:
  br label %loop
loop:
  %acc = phi i64 [ 0, %entry ], [ %or, %loop ]
  %j = phi i64 [ 0, %entry ], [ %j.next, %loop ]
  %p = getelementptr inbounds i32, ptr %base, i64 %j
  %v = load i32, ptr %p, align 4
  %c = icmp slt i32 %v, %k
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

; Arbitrary computation feeding the compare is fine: the loop vectorizer
; widens it as usual and only the packing step is special-cased.
define i64 @bitpack_computed_operand(ptr %base, i32 %k) {
; CHECK-LABEL: @bitpack_computed_operand(
; CHECK:       vector.body:
; CHECK:         %[[C:.*]] = icmp ugt <8 x i32>
; CHECK:         bitcast <8 x i1> %[[C]] to i8
entry:
  br label %loop
loop:
  %acc = phi i64 [ 0, %entry ], [ %or, %loop ]
  %j = phi i64 [ 0, %entry ], [ %j.next, %loop ]
  %p = getelementptr inbounds i32, ptr %base, i64 %j
  %v = load i32, ptr %p, align 4
  %m = mul i32 %v, 3
  %c = icmp ugt i32 %m, %k
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

; Two arrays compared elementwise: also fine, for the same reason.
define i64 @bitpack_two_arrays(ptr %a, ptr %b) {
; CHECK-LABEL: @bitpack_two_arrays(
; CHECK:       vector.body:
; CHECK:         %[[C:.*]] = icmp ugt <8 x i32>
; CHECK:         bitcast <8 x i1> %[[C]] to i8
entry:
  br label %loop
loop:
  %acc = phi i64 [ 0, %entry ], [ %or, %loop ]
  %j = phi i64 [ 0, %entry ], [ %j.next, %loop ]
  %pa = getelementptr inbounds i32, ptr %a, i64 %j
  %pb = getelementptr inbounds i32, ptr %b, i64 %j
  %va = load i32, ptr %pa, align 4
  %vb = load i32, ptr %pb, align 4
  %c = icmp ugt i32 %va, %vb
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

; Float compares work too.
define i64 @bitpack_fcmp(ptr %base, float %k) {
; CHECK-LABEL: @bitpack_fcmp(
; CHECK:       vector.body:
; CHECK:         %[[C:.*]] = fcmp ogt <8 x float>
; CHECK:         bitcast <8 x i1> %[[C]] to i8
entry:
  br label %loop
loop:
  %acc = phi i64 [ 0, %entry ], [ %or, %loop ]
  %j = phi i64 [ 0, %entry ], [ %j.next, %loop ]
  %p = getelementptr inbounds float, ptr %base, i64 %j
  %v = load float, ptr %p, align 4
  %c = fcmp ogt float %v, %k
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

; NEGATIVE: bits assigned in reverse order -- lane L would not map to bit L.
define i64 @negative_reversed(ptr %base, i32 %k) {
; CHECK-LABEL: @negative_reversed(
; CHECK-NOT:     bitcast <8 x i1>
entry:
  br label %loop
loop:
  %acc = phi i64 [ 0, %entry ], [ %or, %loop ]
  %j = phi i64 [ 0, %entry ], [ %j.next, %loop ]
  %p = getelementptr inbounds i32, ptr %base, i64 %j
  %v = load i32, ptr %p, align 4
  %c = icmp ugt i32 %v, %k
  %z = zext i1 %c to i64
  %rev = sub i64 63, %j
  %s = shl i64 %z, %rev
  %or = or i64 %s, %acc
  %j.next = add nuw nsw i64 %j, 1
  %ec = icmp eq i64 %j.next, 64
  br i1 %ec, label %exit, label %loop
exit:
  %r = phi i64 [ %or, %loop ]
  ret i64 %r
}

; A narrow accumulator is still packable: LV narrows the induction to match,
; and shifting past the accumulator width is poison in the scalar loop too, so
; the vector form has the same behaviour.
define i8 @bitpack_narrow_acc(ptr %base, i32 %k) {
; CHECK-LABEL: @bitpack_narrow_acc(
; CHECK:       vector.body:
; CHECK:         %[[C:.*]] = icmp ugt <8 x i32>
; CHECK:         bitcast <8 x i1> %[[C]] to i8
entry:
  br label %loop
loop:
  %acc = phi i8 [ 0, %entry ], [ %or, %loop ]
  %j = phi i64 [ 0, %entry ], [ %j.next, %loop ]
  %p = getelementptr inbounds i32, ptr %base, i64 %j
  %v = load i32, ptr %p, align 4
  %c = icmp ugt i32 %v, %k
  %z = zext i1 %c to i8
  %jt = trunc i64 %j to i8
  %s = shl i8 %z, %jt
  %or = or i8 %s, %acc
  %j.next = add nuw nsw i64 %j, 1
  %ec = icmp eq i64 %j.next, 64
  br i1 %ec, label %exit, label %loop
exit:
  %r = phi i8 [ %or, %loop ]
  ret i8 %r
}

; NEGATIVE: a plain or-reduction with no positional shift must be untouched.
define i64 @negative_plain_or(ptr %base) {
; CHECK-LABEL: @negative_plain_or(
; CHECK-NOT:     bitcast <8 x i1>
entry:
  br label %loop
loop:
  %acc = phi i64 [ 0, %entry ], [ %or, %loop ]
  %j = phi i64 [ 0, %entry ], [ %j.next, %loop ]
  %p = getelementptr inbounds i64, ptr %base, i64 %j
  %v = load i64, ptr %p, align 8
  %or = or i64 %v, %acc
  %j.next = add nuw nsw i64 %j, 1
  %ec = icmp eq i64 %j.next, 64
  br i1 %ec, label %exit, label %loop
exit:
  %r = phi i64 [ %or, %loop ]
  ret i64 %r
}
