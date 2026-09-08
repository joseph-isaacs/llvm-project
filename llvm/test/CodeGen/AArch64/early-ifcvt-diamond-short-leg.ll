; RUN: llc -mtriple=aarch64 -mcpu=generic < %s | FileCheck %s
; RUN: llc -mtriple=aarch64 -mcpu=ampere1 < %s | FileCheck %s

; Diamond where the leg with the fewest instructions (the two dependent sdivs)
; has the longest critical path. Early if-conversion used to measure the
; critical path extension only along the trace through that leg, so it
; speculated both legs and let the fast leg (division by a constant) wait for
; the two sdivs behind a csel. Both legs must stay behind the branch.

define i64 @mul_div_i64(i64 %value, i64 %numerator, i64 range(i64 1, 0) %denom) {
; CHECK-LABEL: mul_div_i64:
; CHECK:       // %bb.0: // %start
; CHECK-NOT:     csel
; CHECK:         b.{{ne|eq}} .LBB0_
; CHECK-NOT:     csel
; CHECK:         sdiv
; CHECK-NOT:     csel
; CHECK:         ret
start:
  %cmp = icmp eq i64 %denom, 24000000
  br i1 %cmp, label %bb1, label %bb2

bb1:
  %r.c = srem i64 %value, 24000000
  %rn.c = mul nsw i64 %r.c, 1000000000
  %q.c = sdiv i64 %value, 24000000
  %qn.c = mul i64 %q.c, 1000000000
  %rq.c = sdiv i64 %rn.c, 24000000
  %res.c = add i64 %rq.c, %qn.c
  br label %bb3

bb2:
  %r = srem i64 %value, %denom
  %rn = mul i64 %r, 1000000000
  %q = sdiv i64 %value, %denom
  %qn = mul i64 %q, 1000000000
  %rq = sdiv i64 %rn, %denom
  %res = add i64 %qn, %rq
  br label %bb3

bb3:
  %ret = phi i64 [ %res.c, %bb1 ], [ %res, %bb2 ]
  ret i64 %ret
}
