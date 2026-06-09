; ModuleID = 'vecir64.ll'
source_filename = "vecir64.ll"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none)
define i64 @to_bitmask64(<64 x i1> %m) local_unnamed_addr #0 {
  %r = bitcast <64 x i1> %m to i64
  ret i64 %r
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) "target-cpu"="x86-64-v3" }
