; ModuleID = 'arrow_collect_bool.eca41ef838c30c9e-cgu.0'
source_filename = "arrow_collect_bool.eca41ef838c30c9e-cgu.0"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind nonlazybind uwtable
define void @collect_bool_from_bool_vec(ptr noundef %src, ptr noundef %dst, i64 noundef %chunks) unnamed_addr #0 {
start:
  %iter1 = alloca [8 x i8], align 8
  %iter = alloca [8 x i8], align 8
  %_7 = alloca [16 x i8], align 8
  %packed = alloca [8 x i8], align 8
  %_4 = alloca [16 x i8], align 8
  store i64 0, ptr %iter, align 8
  br label %bb1

bb1:                                              ; preds = %bb6, %start
  call void @llvm.lifetime.start.p0(i64 16, ptr %_4)
  %_19 = load i64, ptr %iter, align 8, !noundef !3
  %_16 = icmp ult i64 %_19, %chunks
  br i1 %_16, label %bb3, label %bb4

bb4:                                              ; preds = %bb1
  call void @llvm.lifetime.end.p0(i64 16, ptr %_4)
  ret void

bb3:                                              ; preds = %bb1
  %_17 = load i64, ptr %iter, align 8, !noundef !3
  %0 = add nuw i64 %_17, 1
  store i64 %0, ptr %iter, align 8
  %1 = getelementptr inbounds i8, ptr %_4, i64 8
  store i64 %_17, ptr %1, align 8
  store i64 1, ptr %_4, align 8
  %2 = getelementptr inbounds i8, ptr %_4, i64 8
  %chunk = load i64, ptr %2, align 8, !noundef !3
  store i64 0, ptr %packed, align 8
  store i64 0, ptr %iter1, align 8
  br label %bb2

bb2:                                              ; preds = %bb5, %bb3
  call void @llvm.lifetime.start.p0(i64 16, ptr %_7)
  %_23 = load i64, ptr %iter1, align 8, !noundef !3
  %_20 = icmp ult i64 %_23, 64
  br i1 %_20, label %bb5, label %bb6

bb6:                                              ; preds = %bb2
  call void @llvm.lifetime.end.p0(i64 16, ptr %_7)
  %_15 = getelementptr inbounds nuw i64, ptr %dst, i64 %chunk
  %3 = load i64, ptr %packed, align 8, !noundef !3
  store i64 %3, ptr %_15, align 8
  call void @llvm.lifetime.end.p0(i64 16, ptr %_4)
  br label %bb1

bb5:                                              ; preds = %bb2
  %_21 = load i64, ptr %iter1, align 8, !noundef !3
  %4 = add nuw i64 %_21, 1
  store i64 %4, ptr %iter1, align 8
  %5 = getelementptr inbounds i8, ptr %_7, i64 8
  store i64 %_21, ptr %5, align 8
  store i64 1, ptr %_7, align 8
  %6 = getelementptr inbounds i8, ptr %_7, i64 8
  %bit_idx = load i64, ptr %6, align 8, !noundef !3
  %_10 = mul i64 %chunk, 64
  %i = add i64 %_10, %bit_idx
  %_14 = getelementptr inbounds nuw i8, ptr %src, i64 %i
  %7 = load i8, ptr %_14, align 1, !range !4, !noundef !3
  %_13 = trunc nuw i8 %7 to i1
  %8 = icmp ule i1 %_13, true
  call void @llvm.assume(i1 %8)
  %_12 = zext i1 %_13 to i64
  %9 = and i64 %bit_idx, 63
  %_11 = shl i64 %_12, %9
  %10 = load i64, ptr %packed, align 8, !noundef !3
  %11 = or i64 %10, %_11
  store i64 %11, ptr %packed, align 8
  call void @llvm.lifetime.end.p0(i64 16, ptr %_7)
  br label %bb2
}

; Function Attrs: nounwind nonlazybind uwtable
define void @collect_bool_from_i32_gt(ptr noundef %src, ptr noundef %dst, i64 noundef %chunks, i32 noundef %k) unnamed_addr #0 {
start:
  %iter1 = alloca [8 x i8], align 8
  %iter = alloca [8 x i8], align 8
  %_8 = alloca [16 x i8], align 8
  %packed = alloca [8 x i8], align 8
  %_5 = alloca [16 x i8], align 8
  store i64 0, ptr %iter, align 8
  br label %bb1

bb1:                                              ; preds = %bb6, %start
  call void @llvm.lifetime.start.p0(i64 16, ptr %_5)
  %_21 = load i64, ptr %iter, align 8, !noundef !3
  %_18 = icmp ult i64 %_21, %chunks
  br i1 %_18, label %bb3, label %bb4

bb4:                                              ; preds = %bb1
  call void @llvm.lifetime.end.p0(i64 16, ptr %_5)
  ret void

bb3:                                              ; preds = %bb1
  %_19 = load i64, ptr %iter, align 8, !noundef !3
  %0 = add nuw i64 %_19, 1
  store i64 %0, ptr %iter, align 8
  %1 = getelementptr inbounds i8, ptr %_5, i64 8
  store i64 %_19, ptr %1, align 8
  store i64 1, ptr %_5, align 8
  %2 = getelementptr inbounds i8, ptr %_5, i64 8
  %chunk = load i64, ptr %2, align 8, !noundef !3
  store i64 0, ptr %packed, align 8
  store i64 0, ptr %iter1, align 8
  br label %bb2

bb2:                                              ; preds = %bb5, %bb3
  call void @llvm.lifetime.start.p0(i64 16, ptr %_8)
  %_25 = load i64, ptr %iter1, align 8, !noundef !3
  %_22 = icmp ult i64 %_25, 64
  br i1 %_22, label %bb5, label %bb6

bb6:                                              ; preds = %bb2
  call void @llvm.lifetime.end.p0(i64 16, ptr %_8)
  %_17 = getelementptr inbounds nuw i64, ptr %dst, i64 %chunk
  %3 = load i64, ptr %packed, align 8, !noundef !3
  store i64 %3, ptr %_17, align 8
  call void @llvm.lifetime.end.p0(i64 16, ptr %_5)
  br label %bb1

bb5:                                              ; preds = %bb2
  %_23 = load i64, ptr %iter1, align 8, !noundef !3
  %4 = add nuw i64 %_23, 1
  store i64 %4, ptr %iter1, align 8
  %5 = getelementptr inbounds i8, ptr %_8, i64 8
  store i64 %_23, ptr %5, align 8
  store i64 1, ptr %_8, align 8
  %6 = getelementptr inbounds i8, ptr %_8, i64 8
  %bit_idx = load i64, ptr %6, align 8, !noundef !3
  %_11 = mul i64 %chunk, 64
  %i = add i64 %_11, %bit_idx
  %_16 = getelementptr inbounds nuw i32, ptr %src, i64 %i
  %_15 = load i32, ptr %_16, align 4, !noundef !3
  %_14 = icmp sgt i32 %_15, %k
  %7 = icmp ule i1 %_14, true
  call void @llvm.assume(i1 %7)
  %_13 = zext i1 %_14 to i64
  %8 = and i64 %bit_idx, 63
  %_12 = shl i64 %_13, %8
  %9 = load i64, ptr %packed, align 8, !noundef !3
  %10 = or i64 %9, %_12
  store i64 %10, ptr %packed, align 8
  call void @llvm.lifetime.end.p0(i64 16, ptr %_8)
  br label %bb2
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #2

attributes #0 = { nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 2, !"RtLibUseGOT", i32 1}
!2 = !{!"rustc version 1.94.1 (e408947bf 2026-03-25)"}
!3 = !{}
!4 = !{i8 0, i8 2}
