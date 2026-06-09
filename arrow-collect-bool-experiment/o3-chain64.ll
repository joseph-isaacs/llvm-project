; ModuleID = 'chain64.ll'
source_filename = "chain64.ll"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define i64 @chain64_i32_sgt(ptr nofree readonly %src, i32 %k) local_unnamed_addr #0 {
entry:
  %0 = load <64 x i32>, ptr %src, align 1
  %1 = insertelement <64 x i32> poison, i32 %k, i64 0
  %2 = shufflevector <64 x i32> %1, <64 x i32> poison, <64 x i32> zeroinitializer
  %3 = icmp sgt <64 x i32> %0, %2
  %4 = bitcast <64 x i1> %3 to i64
  ret i64 %4
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define i64 @chain64_bool(ptr nofree readonly %src, i32 %k) local_unnamed_addr #0 {
entry:
  %0 = load <64 x i8>, ptr %src, align 1
  %1 = icmp ne <64 x i8> %0, zeroinitializer
  %2 = bitcast <64 x i1> %1 to i64
  ret i64 %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define range(i64 0, 256) i64 @chain8_i32_sgt(ptr nofree readonly captures(none) %src, i32 %k) local_unnamed_addr #0 {
entry:
  %0 = load <8 x i32>, ptr %src, align 1
  %1 = insertelement <8 x i32> poison, i32 %k, i64 0
  %2 = shufflevector <8 x i32> %1, <8 x i32> poison, <8 x i32> zeroinitializer
  %3 = icmp sgt <8 x i32> %0, %2
  %4 = bitcast <8 x i1> %3 to i8
  %5 = zext i8 %4 to i64
  ret i64 %5
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) "target-cpu"="x86-64-v3" }
