; RUN: opt -S -passes=loop-vectorize -mtriple=x86_64-- -mcpu=x86-64-v3 < %s | FileCheck %s
; RUN: opt -passes=loop-vectorize -mtriple=x86_64-- -mcpu=x86-64-v3 \
; RUN:   -pass-remarks-analysis=loop-vectorize -disable-output < %s 2>&1 | FileCheck %s --check-prefix=REMARK

; Documents the LoopVectorizer gap: `word |= (v[i] != 0) << i` is a bit-packing
; recurrence, NOT one of LV's recognized reduction kinds, so LV leaves the loop
; scalar.  There is therefore no vectorized IR for a post-pass recognizer to
; rewrite -- the loop idiom must instead be reached via SLP on a strip-mined
; inner block (see loop-strip-mined.ll), or by teaching LV a new recurrence.

; REMARK: loop not vectorized: value that could not be identified as reduction is used outside the loop

define i64 @packloop(ptr %p, i64 %n) {
; CHECK-LABEL: define i64 @packloop(
; CHECK-NOT:   vector.body
; CHECK:         shl i64
entry:
  br label %loop
loop:
  %i = phi i64 [0, %entry], [%i.next, %loop]
  %word = phi i64 [0, %entry], [%word.next, %loop]
  %g = getelementptr i8, ptr %p, i64 %i
  %v = load i8, ptr %g
  %c = icmp ne i8 %v, 0
  %z = zext i1 %c to i64
  %sh = shl i64 %z, %i
  %word.next = or i64 %word, %sh
  %i.next = add i64 %i, 1
  %done = icmp eq i64 %i.next, %n
  br i1 %done, label %exit, label %loop
exit:
  ret i64 %word
}
