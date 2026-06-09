; ModuleID = 'chain64_rustc_form.ll'
source_filename = "chain64_rustc_form.ll"
target datalayout = "e-m:e-p270:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read)
define i64 @chain64_bool_rustc_form(ptr nofree readonly %src) local_unnamed_addr #0 {
entry:
  %0 = load <8 x i8>, ptr %src, align 1
  %1 = shl nuw <8 x i8> %0, <i8 0, i8 1, i8 2, i8 3, i8 4, i8 5, i8 6, i8 7>
  %2 = tail call i8 @llvm.vector.reduce.or.v8i8(<8 x i8> %1)
  %g8 = getelementptr inbounds nuw i8, ptr %src, i64 8
  %g12 = getelementptr inbounds nuw i8, ptr %src, i64 12
  %g15 = getelementptr inbounds nuw i8, ptr %src, i64 15
  %g23 = getelementptr inbounds nuw i8, ptr %src, i64 23
  %3 = load <4 x i8>, ptr %g8, align 1
  %4 = load <3 x i8>, ptr %g12, align 1
  %5 = load <8 x i8>, ptr %g15, align 1
  %6 = load <16 x i8>, ptr %g23, align 1
  %7 = shufflevector <3 x i8> %4, <3 x i8> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  %8 = shufflevector <4 x i8> %3, <4 x i8> %7, <32 x i32> <i32 poison, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison>
  %9 = insertelement <32 x i8> %8, i8 %2, i64 0
  %10 = shufflevector <16 x i8> %6, <16 x i8> poison, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison>
  %11 = shufflevector <32 x i8> %9, <32 x i8> %10, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47>
  %12 = shufflevector <8 x i8> %5, <8 x i8> poison, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison>
  %13 = shufflevector <32 x i8> %11, <32 x i8> %12, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 32, i32 33, i32 34, i32 35, i32 36, i32 37, i32 38, i32 39, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 30, i32 31>
  %14 = zext <32 x i8> %13 to <32 x i64>
  %15 = shl nuw nsw <32 x i64> %14, <i64 0, i64 8, i64 9, i64 10, i64 11, i64 12, i64 13, i64 14, i64 15, i64 16, i64 17, i64 18, i64 19, i64 20, i64 21, i64 22, i64 23, i64 24, i64 25, i64 26, i64 27, i64 28, i64 29, i64 30, i64 31, i64 32, i64 33, i64 34, i64 35, i64 36, i64 37, i64 38>
  %g39 = getelementptr inbounds nuw i8, ptr %src, i64 39
  %16 = load <16 x i8>, ptr %g39, align 1
  %17 = zext <16 x i8> %16 to <16 x i64>
  %18 = shl nuw nsw <16 x i64> %17, <i64 39, i64 40, i64 41, i64 42, i64 43, i64 44, i64 45, i64 46, i64 47, i64 48, i64 49, i64 50, i64 51, i64 52, i64 53, i64 54>
  %g55 = getelementptr inbounds nuw i8, ptr %src, i64 55
  %19 = load <8 x i8>, ptr %g55, align 1
  %20 = zext <8 x i8> %19 to <8 x i64>
  %21 = shl nuw nsw <8 x i64> %20, <i64 55, i64 56, i64 57, i64 58, i64 59, i64 60, i64 61, i64 62>
  %g63 = getelementptr inbounds nuw i8, ptr %src, i64 63
  %v63 = load i8, ptr %g63, align 1, !range !0
  %t63 = zext nneg i8 %v63 to i64
  %s63 = shl nuw i64 %t63, 63
  %22 = shufflevector <32 x i64> %15, <32 x i64> poison, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
  %rdx.op = or <16 x i64> %22, %18
  %23 = shufflevector <16 x i64> %rdx.op, <16 x i64> poison, <32 x i32> <i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison>
  %24 = shufflevector <32 x i64> %23, <32 x i64> %15, <32 x i32> <i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63>
  %25 = shufflevector <16 x i64> %rdx.op, <16 x i64> poison, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %rdx.op17 = or <8 x i64> %25, %21
  %26 = shufflevector <8 x i64> %rdx.op17, <8 x i64> poison, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison, i32 poison>
  %27 = shufflevector <32 x i64> %26, <32 x i64> %24, <32 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 40, i32 41, i32 42, i32 43, i32 44, i32 45, i32 46, i32 47, i32 48, i32 49, i32 50, i32 51, i32 52, i32 53, i32 54, i32 55, i32 56, i32 57, i32 58, i32 59, i32 60, i32 61, i32 62, i32 63>
  %28 = tail call i64 @llvm.vector.reduce.or.v32i64(<32 x i64> %27)
  %op.rdx = or i64 %28, %s63
  ret i64 %op.rdx
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.vector.reduce.or.v32i64(<32 x i64>) #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i8 @llvm.vector.reduce.or.v8i8(<8 x i8>) #1

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: read) "target-cpu"="x86-64-v3" }
attributes #1 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }

!0 = !{i8 0, i8 2}
