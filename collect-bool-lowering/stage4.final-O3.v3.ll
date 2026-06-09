; ModuleID = 'collect_bool.O0.v3.ll'
source_filename = "collect_bool.b8286983fdd6b685-cgu.0"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@alloc_6957e294861d181a0a9ce74760eb0966 = private unnamed_addr constant [37 x i8] c"assertion failed: dst.len() >= chunks", align 1
@alloc_f27b21102cf09835659d28bbfc97b329 = private unnamed_addr constant [16 x i8] c"collect_bool.rs\00", align 1
@alloc_74638943da2922824d60629cbfb02232 = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00\0C\00\00\00\05\00\00\00" }>, align 8
@alloc_f8b5cd2d0201c42fe0e3a94f0cc4a75a = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00\10\00\00\00\19\00\00\00" }>, align 8
@alloc_9b24b8bc0a0d53448541ad776ac7579d = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00\1C\00\00\00\05\00\00\00" }>, align 8

; Function Attrs: inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(argmem: readwrite) uwtable
define { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17h52a5946471487a67E"(ptr nofree align 8 captures(none) %self) unnamed_addr #0 {
start:
  %_4.i = getelementptr inbounds nuw i8, ptr %self, i64 8
  %_3.i.i = load i64, ptr %self, align 8
  %_4.i.i = load i64, ptr %_4.i, align 8
  %_0.i.i = icmp ult i64 %_3.i.i, %_4.i.i
  br i1 %_0.i.i, label %bb2.i, label %"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h9fce37053dc85e9eE.exit"

bb2.i:                                            ; preds = %start
  %_0.i1.i = add nuw i64 %_3.i.i, 1
  store i64 %_0.i1.i, ptr %self, align 8
  br label %"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h9fce37053dc85e9eE.exit"

"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h9fce37053dc85e9eE.exit": ; preds = %start, %bb2.i
  %_0.sroa.0.0.i = phi i64 [ 1, %bb2.i ], [ 0, %start ]
  %0 = insertvalue { i64, i64 } poison, i64 %_0.sroa.0.0.i, 0
  %1 = insertvalue { i64, i64 } %0, i64 %_3.i.i, 1
  ret { i64, i64 } %1
}

; Function Attrs: inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(none) uwtable
define align 1 ptr @"_ZN4core5slice29_$LT$impl$u20$$u5b$T$u5d$$GT$13get_unchecked17hc0fc15b0f52b5203E"(ptr nofree readnone align 1 captures(ret: address, provenance) %self.0, i64 %self.1, i64 %index, ptr nofree readnone align 8 captures(none) %0) unnamed_addr #1 {
start:
  %_0.i = getelementptr inbounds nuw i8, ptr %self.0, i64 %index
  ret ptr %_0.i
}

; Function Attrs: inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(none) uwtable
define align 8 ptr @"_ZN4core5slice29_$LT$impl$u20$$u5b$T$u5d$$GT$17get_unchecked_mut17h342d343e67607f02E"(ptr nofree readnone align 8 captures(ret: address, provenance) %self.0, i64 %self.1, i64 %index, ptr nofree readnone align 8 captures(none) %0) unnamed_addr #1 {
start:
  %_0.i = getelementptr inbounds nuw [8 x i8], ptr %self.0, i64 %index
  ret ptr %_0.i
}

; Function Attrs: inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(none) uwtable
define { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h7832bcb16f94822eE"(i64 %self.0, i64 %self.1) unnamed_addr #1 {
start:
  %0 = insertvalue { i64, i64 } poison, i64 %self.0, 0
  %1 = insertvalue { i64, i64 } %0, i64 %self.1, 1
  ret { i64, i64 } %1
}

; Function Attrs: inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(none) uwtable
define ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$13get_unchecked17h6403856dd64b9aa4E"(i64 %self, ptr nofree readnone captures(ret: address, provenance) %slice.0, i64 %slice.1, ptr nofree readnone align 8 captures(none) %0) unnamed_addr #1 {
start:
  %_0 = getelementptr inbounds nuw i8, ptr %slice.0, i64 %self
  ret ptr %_0
}

; Function Attrs: inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(none) uwtable
define ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$17get_unchecked_mut17hc032a06ca74226baE"(i64 %self, ptr nofree readnone captures(ret: address, provenance) %slice.0, i64 %slice.1, ptr nofree readnone align 8 captures(none) %0) unnamed_addr #1 {
start:
  %_0 = getelementptr inbounds nuw [8 x i8], ptr %slice.0, i64 %self
  ret ptr %_0
}

; Function Attrs: inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(argmem: readwrite) uwtable
define { i64, i64 } @"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h9fce37053dc85e9eE"(ptr nofree align 8 captures(none) %self) unnamed_addr #0 {
start:
  %_4 = getelementptr inbounds nuw i8, ptr %self, i64 8
  %_3.i = load i64, ptr %self, align 8
  %_4.i = load i64, ptr %_4, align 8
  %_0.i = icmp ult i64 %_3.i, %_4.i
  br i1 %_0.i, label %bb2, label %bb5

bb2:                                              ; preds = %start
  %_0.i1 = add nuw i64 %_3.i, 1
  store i64 %_0.i1, ptr %self, align 8
  br label %bb5

bb5:                                              ; preds = %start, %bb2
  %_0.sroa.0.0 = phi i64 [ 1, %bb2 ], [ 0, %start ]
  %0 = insertvalue { i64, i64 } poison, i64 %_0.sroa.0.0, 0
  %1 = insertvalue { i64, i64 } %0, i64 %_3.i, 1
  ret { i64, i64 } %1
}

; Function Attrs: nounwind nonlazybind uwtable
define void @collect_bool(ptr nofree readonly align 1 captures(none) %src.0, i64 %src.1, ptr nofree writeonly align 8 captures(none) %dst.0, i64 %dst.1) unnamed_addr #2 {
start:
  %chunks4 = lshr i64 %src.1, 6
  %_6.not = icmp ult i64 %dst.1, %chunks4
  br i1 %_6.not, label %bb3, label %bb5.preheader.split

bb5.preheader.split:                              ; preds = %start
  %_0.i.i.i24.not = icmp eq i64 %chunks4, 0
  br i1 %_0.i.i.i24.not, label %bb9, label %bb8

bb3:                                              ; preds = %start
  tail call void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr nonnull align 1 @alloc_6957e294861d181a0a9ce74760eb0966, i64 37, ptr nonnull align 8 @alloc_74638943da2922824d60629cbfb02232) #6
  unreachable

bb8:                                              ; preds = %bb5.preheader.split, %bb14
  %iter.sroa.0.025 = phi i64 [ %_0.i1.i.i, %bb14 ], [ 0, %bb5.preheader.split ]
  %0 = shl nuw i64 %iter.sroa.0.025, 6
  %umax = tail call i64 @llvm.umax.i64(i64 %src.1, i64 %0)
  %1 = shl i64 %iter.sroa.0.025, 6
  %2 = sub i64 %umax, %1
  %_0.i1.i.i = add nuw nsw i64 %iter.sroa.0.025, 1
  %_30 = shl i64 %iter.sroa.0.025, 6
  %min.iters.check = icmp ult i64 %2, 16
  br i1 %min.iters.check, label %bb13.preheader, label %vector.ph

vector.ph:                                        ; preds = %bb8
  %umin = tail call i64 @llvm.umin.i64(i64 %2, i64 63)
  %3 = add nuw nsw i64 %umin, 1
  %n.mod.vf = and i64 %3, 15
  %4 = icmp eq i64 %n.mod.vf, 0
  %5 = select i1 %4, i64 16, i64 %n.mod.vf
  %n.vec = sub nsw i64 %3, %5
  %invariant.gep = getelementptr i8, ptr %src.0, i64 %_30
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <4 x i64> [ zeroinitializer, %vector.ph ], [ %21, %vector.body ]
  %vec.phi30 = phi <4 x i64> [ zeroinitializer, %vector.ph ], [ %22, %vector.body ]
  %vec.phi31 = phi <4 x i64> [ zeroinitializer, %vector.ph ], [ %23, %vector.body ]
  %vec.phi32 = phi <4 x i64> [ zeroinitializer, %vector.ph ], [ %24, %vector.body ]
  %vec.ind = phi <4 x i64> [ <i64 0, i64 1, i64 2, i64 3>, %vector.ph ], [ %vec.ind.next, %vector.body ]
  %step.add = add nuw <4 x i64> %vec.ind, splat (i64 4)
  %step.add.2 = add nuw <4 x i64> %vec.ind, splat (i64 8)
  %step.add.3 = add nuw <4 x i64> %vec.ind, splat (i64 12)
  %gep = getelementptr i8, ptr %invariant.gep, i64 %index
  %6 = getelementptr inbounds nuw i8, ptr %gep, i64 4
  %7 = getelementptr inbounds nuw i8, ptr %gep, i64 8
  %8 = getelementptr inbounds nuw i8, ptr %gep, i64 12
  %wide.load = load <4 x i8>, ptr %gep, align 1
  %wide.load33 = load <4 x i8>, ptr %6, align 1
  %wide.load34 = load <4 x i8>, ptr %7, align 1
  %wide.load35 = load <4 x i8>, ptr %8, align 1
  %9 = icmp ne <4 x i8> %wide.load, zeroinitializer
  %10 = icmp ne <4 x i8> %wide.load33, zeroinitializer
  %11 = icmp ne <4 x i8> %wide.load34, zeroinitializer
  %12 = icmp ne <4 x i8> %wide.load35, zeroinitializer
  %13 = zext <4 x i1> %9 to <4 x i64>
  %14 = zext <4 x i1> %10 to <4 x i64>
  %15 = zext <4 x i1> %11 to <4 x i64>
  %16 = zext <4 x i1> %12 to <4 x i64>
  %17 = shl nuw <4 x i64> %13, %vec.ind
  %18 = shl nuw <4 x i64> %14, %step.add
  %19 = shl nuw <4 x i64> %15, %step.add.2
  %20 = shl nuw <4 x i64> %16, %step.add.3
  %21 = or <4 x i64> %17, %vec.phi
  %22 = or <4 x i64> %18, %vec.phi30
  %23 = or <4 x i64> %19, %vec.phi31
  %24 = or <4 x i64> %20, %vec.phi32
  %index.next = add nuw i64 %index, 16
  %vec.ind.next = add nuw <4 x i64> %vec.ind, splat (i64 16)
  %25 = icmp eq i64 %index.next, %n.vec
  br i1 %25, label %middle.block, label %vector.body, !llvm.loop !3

middle.block:                                     ; preds = %vector.body
  %bin.rdx = or <4 x i64> %22, %21
  %bin.rdx36 = or <4 x i64> %23, %bin.rdx
  %bin.rdx37 = or <4 x i64> %24, %bin.rdx36
  %26 = tail call i64 @llvm.vector.reduce.or.v4i64(<4 x i64> %bin.rdx37)
  br label %bb13.preheader

bb13.preheader:                                   ; preds = %bb8, %middle.block
  %packed.sroa.0.023.ph = phi i64 [ 0, %bb8 ], [ %26, %middle.block ]
  %iter1.sroa.0.022.ph = phi i64 [ 0, %bb8 ], [ %n.vec, %middle.block ]
  br label %bb13

bb9:                                              ; preds = %bb14, %bb5.preheader.split
  ret void

bb13:                                             ; preds = %bb13.preheader, %bb15
  %packed.sroa.0.023 = phi i64 [ %29, %bb15 ], [ %packed.sroa.0.023.ph, %bb13.preheader ]
  %iter1.sroa.0.022 = phi i64 [ %_0.i1.i.i11, %bb15 ], [ %iter1.sroa.0.022.ph, %bb13.preheader ]
  %_29 = add nuw nsw i64 %iter1.sroa.0.022, %_30
  %_32 = icmp ult i64 %_29, %src.1
  br i1 %_32, label %bb15, label %panic2

bb14:                                             ; preds = %bb15
  %27 = getelementptr inbounds nuw [8 x i8], ptr %dst.0, i64 %iter.sroa.0.025
  store i64 %29, ptr %27, align 8
  %exitcond27.not = icmp eq i64 %_0.i1.i.i, %chunks4
  br i1 %exitcond27.not, label %bb9, label %bb8

bb15:                                             ; preds = %bb13
  %_0.i1.i.i11 = add nuw nsw i64 %iter1.sroa.0.022, 1
  %28 = getelementptr inbounds nuw i8, ptr %src.0, i64 %_29
  %_28 = load i8, ptr %28, align 1
  %_27 = icmp ne i8 %_28, 0
  %_26 = zext i1 %_27 to i64
  %_25 = shl nuw i64 %_26, %iter1.sroa.0.022
  %29 = or i64 %_25, %packed.sroa.0.023
  %exitcond.not = icmp eq i64 %_0.i1.i.i11, 64
  br i1 %exitcond.not, label %bb14, label %bb13, !llvm.loop !6

panic2:                                           ; preds = %bb13
  tail call void @_ZN4core9panicking18panic_bounds_check17h9ae613628793029fE(i64 %_29, i64 %src.1, ptr nonnull align 8 @alloc_f8b5cd2d0201c42fe0e3a94f0cc4a75a) #6
  unreachable
}

; Function Attrs: nounwind nonlazybind uwtable
define void @collect_bool_unchecked(ptr nofree readonly align 1 captures(none) %src.0, i64 %src.1, ptr nofree writeonly align 8 captures(none) %dst.0, i64 %dst.1) unnamed_addr #2 {
start:
  %chunks4 = lshr i64 %src.1, 6
  %_6.not = icmp ult i64 %dst.1, %chunks4
  br i1 %_6.not, label %bb3, label %bb5.preheader

bb5.preheader:                                    ; preds = %start
  %_0.i.i.i22.not = icmp eq i64 %chunks4, 0
  br i1 %_0.i.i.i22.not, label %bb9, label %bb8

bb3:                                              ; preds = %start
  tail call void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr nonnull align 1 @alloc_6957e294861d181a0a9ce74760eb0966, i64 37, ptr nonnull align 8 @alloc_9b24b8bc0a0d53448541ad776ac7579d) #6
  unreachable

bb8:                                              ; preds = %bb5.preheader, %bb8
  %iter.sroa.0.023 = phi i64 [ %_0.i1.i.i, %bb8 ], [ 0, %bb5.preheader ]
  %_29 = shl i64 %iter.sroa.0.023, 6
  %0 = getelementptr inbounds nuw i8, ptr %src.0, i64 %_29
  %1 = getelementptr inbounds nuw i8, ptr %0, i64 4
  %2 = getelementptr inbounds nuw i8, ptr %0, i64 8
  %3 = getelementptr inbounds nuw i8, ptr %0, i64 12
  %wide.load = load <4 x i8>, ptr %0, align 1
  %wide.load28 = load <4 x i8>, ptr %1, align 1
  %wide.load29 = load <4 x i8>, ptr %2, align 1
  %wide.load30 = load <4 x i8>, ptr %3, align 1
  %.not = icmp eq <4 x i8> %wide.load, zeroinitializer
  %.not38 = icmp eq <4 x i8> %wide.load28, zeroinitializer
  %.not39 = icmp eq <4 x i8> %wide.load29, zeroinitializer
  %.not40 = icmp eq <4 x i8> %wide.load30, zeroinitializer
  %4 = select <4 x i1> %.not, <4 x i64> zeroinitializer, <4 x i64> <i64 1, i64 2, i64 4, i64 8>
  %5 = select <4 x i1> %.not38, <4 x i64> zeroinitializer, <4 x i64> <i64 16, i64 32, i64 64, i64 128>
  %6 = select <4 x i1> %.not39, <4 x i64> zeroinitializer, <4 x i64> <i64 256, i64 512, i64 1024, i64 2048>
  %7 = select <4 x i1> %.not40, <4 x i64> zeroinitializer, <4 x i64> <i64 4096, i64 8192, i64 16384, i64 32768>
  %8 = getelementptr inbounds nuw i8, ptr %0, i64 16
  %9 = getelementptr inbounds nuw i8, ptr %0, i64 20
  %10 = getelementptr inbounds nuw i8, ptr %0, i64 24
  %11 = getelementptr inbounds nuw i8, ptr %0, i64 28
  %wide.load.1 = load <4 x i8>, ptr %8, align 1
  %wide.load28.1 = load <4 x i8>, ptr %9, align 1
  %wide.load29.1 = load <4 x i8>, ptr %10, align 1
  %wide.load30.1 = load <4 x i8>, ptr %11, align 1
  %.not41 = icmp eq <4 x i8> %wide.load.1, zeroinitializer
  %.not42 = icmp eq <4 x i8> %wide.load28.1, zeroinitializer
  %.not43 = icmp eq <4 x i8> %wide.load29.1, zeroinitializer
  %.not44 = icmp eq <4 x i8> %wide.load30.1, zeroinitializer
  %12 = select <4 x i1> %.not41, <4 x i64> zeroinitializer, <4 x i64> <i64 65536, i64 131072, i64 262144, i64 524288>
  %13 = select <4 x i1> %.not42, <4 x i64> zeroinitializer, <4 x i64> <i64 1048576, i64 2097152, i64 4194304, i64 8388608>
  %14 = select <4 x i1> %.not43, <4 x i64> zeroinitializer, <4 x i64> <i64 16777216, i64 33554432, i64 67108864, i64 134217728>
  %15 = select <4 x i1> %.not44, <4 x i64> zeroinitializer, <4 x i64> <i64 268435456, i64 536870912, i64 1073741824, i64 2147483648>
  %16 = or disjoint <4 x i64> %12, %4
  %17 = or disjoint <4 x i64> %13, %5
  %18 = or disjoint <4 x i64> %14, %6
  %19 = or disjoint <4 x i64> %15, %7
  %20 = getelementptr inbounds nuw i8, ptr %0, i64 32
  %21 = getelementptr inbounds nuw i8, ptr %0, i64 36
  %22 = getelementptr inbounds nuw i8, ptr %0, i64 40
  %23 = getelementptr inbounds nuw i8, ptr %0, i64 44
  %wide.load.2 = load <4 x i8>, ptr %20, align 1
  %wide.load28.2 = load <4 x i8>, ptr %21, align 1
  %wide.load29.2 = load <4 x i8>, ptr %22, align 1
  %wide.load30.2 = load <4 x i8>, ptr %23, align 1
  %.not45 = icmp eq <4 x i8> %wide.load.2, zeroinitializer
  %.not46 = icmp eq <4 x i8> %wide.load28.2, zeroinitializer
  %.not47 = icmp eq <4 x i8> %wide.load29.2, zeroinitializer
  %.not48 = icmp eq <4 x i8> %wide.load30.2, zeroinitializer
  %24 = select <4 x i1> %.not45, <4 x i64> zeroinitializer, <4 x i64> <i64 4294967296, i64 8589934592, i64 17179869184, i64 34359738368>
  %25 = select <4 x i1> %.not46, <4 x i64> zeroinitializer, <4 x i64> <i64 68719476736, i64 137438953472, i64 274877906944, i64 549755813888>
  %26 = select <4 x i1> %.not47, <4 x i64> zeroinitializer, <4 x i64> <i64 1099511627776, i64 2199023255552, i64 4398046511104, i64 8796093022208>
  %27 = select <4 x i1> %.not48, <4 x i64> zeroinitializer, <4 x i64> <i64 17592186044416, i64 35184372088832, i64 70368744177664, i64 140737488355328>
  %28 = or disjoint <4 x i64> %24, %16
  %29 = or disjoint <4 x i64> %25, %17
  %30 = or disjoint <4 x i64> %26, %18
  %31 = or disjoint <4 x i64> %27, %19
  %32 = getelementptr inbounds nuw i8, ptr %0, i64 48
  %33 = getelementptr inbounds nuw i8, ptr %0, i64 52
  %34 = getelementptr inbounds nuw i8, ptr %0, i64 56
  %35 = getelementptr inbounds nuw i8, ptr %0, i64 60
  %wide.load.3 = load <4 x i8>, ptr %32, align 1
  %wide.load28.3 = load <4 x i8>, ptr %33, align 1
  %wide.load29.3 = load <4 x i8>, ptr %34, align 1
  %wide.load30.3 = load <4 x i8>, ptr %35, align 1
  %.not49 = icmp eq <4 x i8> %wide.load.3, zeroinitializer
  %.not50 = icmp eq <4 x i8> %wide.load28.3, zeroinitializer
  %.not51 = icmp eq <4 x i8> %wide.load29.3, zeroinitializer
  %.not52 = icmp eq <4 x i8> %wide.load30.3, zeroinitializer
  %36 = select <4 x i1> %.not49, <4 x i64> zeroinitializer, <4 x i64> <i64 281474976710656, i64 562949953421312, i64 1125899906842624, i64 2251799813685248>
  %37 = select <4 x i1> %.not50, <4 x i64> zeroinitializer, <4 x i64> <i64 4503599627370496, i64 9007199254740992, i64 18014398509481984, i64 36028797018963968>
  %38 = select <4 x i1> %.not51, <4 x i64> zeroinitializer, <4 x i64> <i64 72057594037927936, i64 144115188075855872, i64 288230376151711744, i64 576460752303423488>
  %39 = select <4 x i1> %.not52, <4 x i64> zeroinitializer, <4 x i64> <i64 1152921504606846976, i64 2305843009213693952, i64 4611686018427387904, i64 -9223372036854775808>
  %40 = or disjoint <4 x i64> %36, %28
  %41 = or disjoint <4 x i64> %37, %29
  %42 = or disjoint <4 x i64> %38, %30
  %43 = or disjoint <4 x i64> %39, %31
  %bin.rdx = or disjoint <4 x i64> %41, %40
  %bin.rdx31 = or disjoint <4 x i64> %42, %bin.rdx
  %bin.rdx32 = or <4 x i64> %43, %bin.rdx31
  %44 = tail call i64 @llvm.vector.reduce.or.v4i64(<4 x i64> %bin.rdx32)
  %_0.i1.i.i = add nuw nsw i64 %iter.sroa.0.023, 1
  %_0.i.i13 = getelementptr inbounds nuw [8 x i8], ptr %dst.0, i64 %iter.sroa.0.023
  store i64 %44, ptr %_0.i.i13, align 8
  %exitcond24.not = icmp eq i64 %_0.i1.i.i, %chunks4
  br i1 %exitcond24.not, label %bb9, label %bb8

bb9:                                              ; preds = %bb8, %bb5.preheader
  ret void
}

; Function Attrs: cold noinline noreturn nounwind nonlazybind uwtable
declare void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr align 1, i64, ptr align 8) unnamed_addr #3

; Function Attrs: cold minsize noinline noreturn nounwind nonlazybind optsize uwtable
declare void @_ZN4core9panicking18panic_bounds_check17h9ae613628793029fE(i64, i64, ptr align 8) unnamed_addr #4

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umax.i64(i64, i64) #5

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.umin.i64(i64, i64) #5

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.vector.reduce.or.v4i64(<4 x i64>) #5

attributes #0 = { inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(argmem: readwrite) uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #1 = { inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(none) uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #2 = { nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #3 = { cold noinline noreturn nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #4 = { cold minsize noinline noreturn nounwind nonlazybind optsize uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #5 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #6 = { noinline noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 2, !"RtLibUseGOT", i32 1}
!2 = !{!"rustc version 1.94.1 (e408947bf 2026-03-25)"}
!3 = distinct !{!3, !4, !5}
!4 = !{!"llvm.loop.isvectorized", i32 1}
!5 = !{!"llvm.loop.unroll.runtime.disable"}
!6 = distinct !{!6, !5, !4}
