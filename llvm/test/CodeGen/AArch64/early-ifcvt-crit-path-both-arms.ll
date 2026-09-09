; RUN: llc -mtriple=aarch64 -mcpu=apple-m1 -early-ifcvt-limit-both-arms=false < %s | FileCheck %s --check-prefix=OLD
; RUN: llc -mtriple=aarch64 -mcpu=apple-m1 -early-ifcvt-limit-both-arms=true  < %s | FileCheck %s --check-prefix=NEW

; The early if-conversion cost model budgets the critical-path extension against
; the trace through Tail. For a diamond both arms have the same InstrDepth, so
; MinInstrCountEnsemble::pickTracePred() ties and keeps whichever predecessor it
; visits first. The arm that ends up setting the budget is therefore decided by
; block order rather than by cost, and when it is the slow arm the cost paid by
; the fast arm is invisible.
;
; The two functions below are the same computation with the branch inverted.
; Both speculate a udiv (~10 cycles on apple-m1) past a shift (~1 cycle), so
; both should be rejected -- the limit is 8 cycles. Before the fix only one of
; them was.

define void @slow_arm_is_false(ptr %a, ptr %b, ptr %out, i32 %n) {
; OLD-LABEL: slow_arm_is_false:
; OLD-NOT:     csel
;
; NEW-LABEL: slow_arm_is_false:
; NEW-NOT:     csel
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %latch ]
  %pa = getelementptr inbounds i32, ptr %a, i32 %i
  %va = load i32, ptr %pa
  %pb = getelementptr inbounds i32, ptr %b, i32 %i
  %vb = load i32, ptr %pb
  %bit = and i32 %va, 1
  %c = icmp eq i32 %bit, 0
  br i1 %c, label %slow, label %fast
slow:
  %q = udiv i32 %va, %vb
  br label %latch
fast:
  %f = lshr i32 %va, 3
  br label %latch
latch:
  %r = phi i32 [ %q, %slow ], [ %f, %fast ]
  %po = getelementptr inbounds i32, ptr %out, i32 %i
  store i32 %r, ptr %po
  %i.next = add nuw nsw i32 %i, 1
  %ec = icmp eq i32 %i.next, %n
  br i1 %ec, label %done, label %loop
done:
  ret void
}

; Same code, inverted branch. The slow arm now sets the budget, so the old cost
; model measured the divide against itself, priced the conversion at 1 cycle,
; and speculated the divide into every iteration.
define void @slow_arm_is_true(ptr %a, ptr %b, ptr %out, i32 %n) {
; OLD-LABEL: slow_arm_is_true:
; OLD:         udiv
; OLD:         csel
;
; NEW-LABEL: slow_arm_is_true:
; NEW-NOT:     csel
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %latch ]
  %pa = getelementptr inbounds i32, ptr %a, i32 %i
  %va = load i32, ptr %pa
  %pb = getelementptr inbounds i32, ptr %b, i32 %i
  %vb = load i32, ptr %pb
  %bit = and i32 %va, 1
  %c = icmp eq i32 %bit, 0
  br i1 %c, label %fast, label %slow
slow:
  %q = udiv i32 %va, %vb
  br label %latch
fast:
  %f = lshr i32 %va, 3
  br label %latch
latch:
  %r = phi i32 [ %q, %slow ], [ %f, %fast ]
  %po = getelementptr inbounds i32, ptr %out, i32 %i
  store i32 %r, ptr %po
  %i.next = add nuw nsw i32 %i, 1
  %ec = icmp eq i32 %i.next, %n
  br i1 %ec, label %done, label %loop
done:
  ret void
}

; Control: two arms of equal depth, each too long for ISel to fold into a
; select, so the cost model really does run. Nothing to lose, keep converting.
define void @balanced_multi(ptr %a, ptr %b, ptr %out, i32 %n) {
; OLD-LABEL: balanced_multi:
; OLD:         csel
;
; NEW-LABEL: balanced_multi:
; NEW:         csel
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %latch ]
  %pa = getelementptr inbounds i32, ptr %a, i32 %i
  %va = load i32, ptr %pa
  %pb = getelementptr inbounds i32, ptr %b, i32 %i
  %vb = load i32, ptr %pb
  %bit = and i32 %va, 1
  %c = icmp eq i32 %bit, 0
  br i1 %c, label %t, label %f
t:
  %t1 = add i32 %va, %vb
  %t2 = xor i32 %t1, 3
  %t3 = add i32 %t2, %va
  br label %latch
f:
  %f1 = sub i32 %va, %vb
  %f2 = xor i32 %f1, 5
  %f3 = sub i32 %f2, %va
  br label %latch
latch:
  %r = phi i32 [ %t3, %t ], [ %f3, %f ]
  %po = getelementptr inbounds i32, ptr %out, i32 %i
  store i32 %r, ptr %po
  %i.next = add nuw nsw i32 %i, 1
  %ec = icmp eq i32 %i.next, %n
  br i1 %ec, label %done, label %loop
done:
  ret void
}

; Control: a real 6-cycle imbalance between the arms. The fix prices this
; honestly (7 cycles rather than the 1 the old model reported) but 7 is still
; inside the 8-cycle budget, so this must keep converting. Guards against the
; new bound being too conservative.
define void @mildly_imbalanced(ptr %a, ptr %b, ptr %out, i32 %n) {
; OLD-LABEL: mildly_imbalanced:
; OLD:         csel
;
; NEW-LABEL: mildly_imbalanced:
; NEW:         csel
entry:
  br label %loop
loop:
  %i = phi i32 [ 0, %entry ], [ %i.next, %latch ]
  %pa = getelementptr inbounds i32, ptr %a, i32 %i
  %va = load i32, ptr %pa
  %pb = getelementptr inbounds i32, ptr %b, i32 %i
  %vb = load i32, ptr %pb
  %bit = and i32 %va, 1
  %c = icmp eq i32 %bit, 0
  br i1 %c, label %t, label %f
t:
  %t1 = add i32 %va, %vb
  %t2 = xor i32 %t1, 3
  %t3 = add i32 %t2, %va
  br label %latch
f:
  %f1 = mul i32 %va, %vb
  %f2 = xor i32 %f1, 5
  %f3 = mul i32 %f2, %va
  br label %latch
latch:
  %r = phi i32 [ %t3, %t ], [ %f3, %f ]
  %po = getelementptr inbounds i32, ptr %out, i32 %i
  store i32 %r, ptr %po
  %i.next = add nuw nsw i32 %i, 1
  %ec = icmp eq i32 %i.next, %n
  br i1 %ec, label %done, label %loop
done:
  ret void
}
