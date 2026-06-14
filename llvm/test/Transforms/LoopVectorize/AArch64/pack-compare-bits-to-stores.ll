; RUN: opt -p loop-vectorize -mtriple=aarch64-linux-gnu -force-vector-width=8 -S %s | FileCheck %s --check-prefix=PACK
; RUN: opt -p loop-vectorize -mtriple=aarch64-linux-gnu -force-vector-width=8 -vplan-pack-compare-bits=false -S %s | FileCheck %s --check-prefix=NOPACK
; RUN: opt -p loop-vectorize -mtriple=aarch64_be-linux-gnu -force-vector-width=8 -S %s | FileCheck %s --check-prefix=NOPACK

; A loop comparing u64 elements against a scalar and packing the boolean
; results positionally into one output byte per 8 inputs. On little-endian the
; interleave group + or-tree should become consecutive wide loads feeding a
; bit-pack (no deinterleave shuffles / scalarized lane loads). On big-endian or
; with the transform disabled, it must not fire.

; PACK-LABEL: define void @pack_byte(
; PACK:       vector.body:
; PACK:         load <8 x i64>
; PACK:         icmp ugt <8 x i64>
; PACK:         bitcast <8 x i1> %{{.*}} to i8
; PACK-NOT:     shufflevector
; PACK:         store <8 x i8>

; NOPACK-LABEL: define void @pack_byte(
; NOPACK-NOT:   bitcast <8 x i1> %{{.*}} to i8

define void @pack_byte(ptr noalias nofree noundef writeonly captures(none) %0, ptr noalias nofree noundef readonly captures(none) %1, i64 noundef %2, i64 noundef %3)  {
  %5 = lshr i64 %2, 3
  %6 = icmp eq i64 %5, 0
  br i1 %6, label %52, label %7

7:                                                ; preds = %4, %7
  %8 = phi i64 [ %50, %7 ], [ 0, %4 ]
  %9 = shl nuw i64 %8, 6
  %10 = getelementptr inbounds nuw i8, ptr %1, i64 %9
  %11 = load i64, ptr %10, align 8
  %12 = icmp ugt i64 %11, %3
  %13 = zext i1 %12 to i8
  %14 = getelementptr inbounds nuw i8, ptr %10, i64 8
  %15 = load i64, ptr %14, align 8
  %16 = icmp ugt i64 %15, %3
  %17 = select i1 %16, i8 2, i8 0
  %18 = or disjoint i8 %17, %13
  %19 = getelementptr inbounds nuw i8, ptr %10, i64 16
  %20 = load i64, ptr %19, align 8
  %21 = icmp ugt i64 %20, %3
  %22 = select i1 %21, i8 4, i8 0
  %23 = or disjoint i8 %18, %22
  %24 = getelementptr inbounds nuw i8, ptr %10, i64 24
  %25 = load i64, ptr %24, align 8
  %26 = icmp ugt i64 %25, %3
  %27 = select i1 %26, i8 8, i8 0
  %28 = or disjoint i8 %23, %27
  %29 = getelementptr inbounds nuw i8, ptr %10, i64 32
  %30 = load i64, ptr %29, align 8
  %31 = icmp ugt i64 %30, %3
  %32 = select i1 %31, i8 16, i8 0
  %33 = or disjoint i8 %28, %32
  %34 = getelementptr inbounds nuw i8, ptr %10, i64 40
  %35 = load i64, ptr %34, align 8
  %36 = icmp ugt i64 %35, %3
  %37 = select i1 %36, i8 32, i8 0
  %38 = or disjoint i8 %33, %37
  %39 = getelementptr inbounds nuw i8, ptr %10, i64 48
  %40 = load i64, ptr %39, align 8
  %41 = icmp ugt i64 %40, %3
  %42 = select i1 %41, i8 64, i8 0
  %43 = or i8 %38, %42
  %44 = getelementptr inbounds nuw i8, ptr %10, i64 56
  %45 = load i64, ptr %44, align 8
  %46 = icmp ugt i64 %45, %3
  %47 = select i1 %46, i8 -128, i8 0
  %48 = or i8 %43, %47
  %49 = getelementptr inbounds nuw i8, ptr %0, i64 %8
  store i8 %48, ptr %49, align 1
  %50 = add nuw nsw i64 %8, 1
  %51 = icmp eq i64 %50, %5
  br i1 %51, label %52, label %7

52:                                               ; preds = %7, %4
  ret void
}
