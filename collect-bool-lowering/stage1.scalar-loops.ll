; ModuleID = 'collect_bool.O0.ll'
source_filename = "collect_bool.b8286983fdd6b685-cgu.0"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@alloc_6957e294861d181a0a9ce74760eb0966 = private unnamed_addr constant [37 x i8] c"assertion failed: dst.len() >= chunks", align 1
@alloc_f27b21102cf09835659d28bbfc97b329 = private unnamed_addr constant [16 x i8] c"collect_bool.rs\00", align 1
@alloc_74638943da2922824d60629cbfb02232 = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00\0C\00\00\00\05\00\00\00" }>, align 8
@alloc_f0b308cc4c9df2d44f594e69a671f9e6 = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00\12\00\00\00\09\00\00\00" }>, align 8
@alloc_f8b5cd2d0201c42fe0e3a94f0cc4a75a = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00\10\00\00\00\19\00\00\00" }>, align 8
@alloc_9b24b8bc0a0d53448541ad776ac7579d = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00\1C\00\00\00\05\00\00\00" }>, align 8
@alloc_223f5ea3b707359a7bb835948d11137a = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00#\00\00\00\17\00\00\00" }>, align 8
@alloc_82f6be90851d0bc80aedf62cb9e353c9 = private unnamed_addr constant <{ ptr, [16 x i8] }> <{ ptr @alloc_f27b21102cf09835659d28bbfc97b329, [16 x i8] c"\0F\00\00\00\00\00\00\00 \00\00\00#\00\00\00" }>, align 8

; Function Attrs: inlinehint nounwind nonlazybind uwtable
define { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17h52a5946471487a67E"(ptr align 8 %self) unnamed_addr #0 {
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
  %_0.i.sroa.0.0 = phi i64 [ 1, %bb2.i ], [ 0, %start ]
  %0 = insertvalue { i64, i64 } poison, i64 %_0.i.sroa.0.0, 0
  %1 = insertvalue { i64, i64 } %0, i64 %_3.i.i, 1
  ret { i64, i64 } %1
}

; Function Attrs: inlinehint nounwind nonlazybind uwtable
define align 1 ptr @"_ZN4core5slice29_$LT$impl$u20$$u5b$T$u5d$$GT$13get_unchecked17hc0fc15b0f52b5203E"(ptr align 1 %self.0, i64 %self.1, i64 %index, ptr align 8 %0) unnamed_addr #0 {
start:
  %_0.i = getelementptr inbounds nuw i8, ptr %self.0, i64 %index
  ret ptr %_0.i
}

; Function Attrs: inlinehint nounwind nonlazybind uwtable
define align 8 ptr @"_ZN4core5slice29_$LT$impl$u20$$u5b$T$u5d$$GT$17get_unchecked_mut17h342d343e67607f02E"(ptr align 8 %self.0, i64 %self.1, i64 %index, ptr align 8 %0) unnamed_addr #0 {
start:
  %_0.i = getelementptr inbounds nuw [8 x i8], ptr %self.0, i64 %index
  ret ptr %_0.i
}

; Function Attrs: inlinehint nounwind nonlazybind uwtable
define { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h7832bcb16f94822eE"(i64 %self.0, i64 %self.1) unnamed_addr #0 {
start:
  %0 = insertvalue { i64, i64 } poison, i64 %self.0, 0
  %1 = insertvalue { i64, i64 } %0, i64 %self.1, 1
  ret { i64, i64 } %1
}

; Function Attrs: inlinehint nounwind nonlazybind uwtable
define ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$13get_unchecked17h6403856dd64b9aa4E"(i64 %self, ptr %slice.0, i64 %slice.1, ptr align 8 %0) unnamed_addr #0 {
start:
  %_0 = getelementptr inbounds nuw i8, ptr %slice.0, i64 %self
  ret ptr %_0
}

; Function Attrs: inlinehint nounwind nonlazybind uwtable
define ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$17get_unchecked_mut17hc032a06ca74226baE"(i64 %self, ptr %slice.0, i64 %slice.1, ptr align 8 %0) unnamed_addr #0 {
start:
  %_0 = getelementptr inbounds nuw [8 x i8], ptr %slice.0, i64 %self
  ret ptr %_0
}

; Function Attrs: inlinehint nounwind nonlazybind uwtable
define { i64, i64 } @"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h9fce37053dc85e9eE"(ptr align 8 %self) unnamed_addr #0 {
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
define void @collect_bool(ptr align 1 %src.0, i64 %src.1, ptr align 8 %dst.0, i64 %dst.1) unnamed_addr #1 {
start:
  %chunks16 = lshr i64 %src.1, 6
  %_6.not = icmp ult i64 %dst.1, %chunks16
  br i1 %_6.not, label %bb3, label %bb5

bb3:                                              ; preds = %start
  call void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr nonnull align 1 @alloc_6957e294861d181a0a9ce74760eb0966, i64 37, ptr nonnull align 8 @alloc_74638943da2922824d60629cbfb02232) #5
  unreachable

bb5:                                              ; preds = %start, %bb16
  %_0.i.i.sroa.5.0 = phi i64 [ %_0.i.i.sroa.5.1, %bb16 ], [ undef, %start ]
  %_0.i.i1.sroa.5.0 = phi i64 [ %_0.i.i1.sroa.5.2, %bb16 ], [ undef, %start ]
  %iter.sroa.0.0 = phi i64 [ %iter.sroa.0.1, %bb16 ], [ 0, %start ]
  %_0.i.i.i = icmp ult i64 %iter.sroa.0.0, %chunks16
  %_0.i.i.sroa.5.1 = select i1 %_0.i.i.i, i64 %iter.sroa.0.0, i64 %_0.i.i.sroa.5.0
  %_0.i1.i.i = zext i1 %_0.i.i.i to i64
  %iter.sroa.0.1 = add nuw i64 %iter.sroa.0.0, %_0.i1.i.i
  br i1 %_0.i.i.i, label %bb11, label %bb9

bb9:                                              ; preds = %bb5
  ret void

bb11:                                             ; preds = %bb5, %bb15
  %iter1.sroa.0.0 = phi i64 [ %iter1.sroa.0.1, %bb15 ], [ 0, %bb5 ]
  %packed.sroa.0.0 = phi i64 [ %3, %bb15 ], [ 0, %bb5 ]
  %_0.i.i1.sroa.5.1 = phi i64 [ %_0.i.i1.sroa.5.2, %bb15 ], [ %_0.i.i1.sroa.5.0, %bb5 ]
  %_0.i.i.i5 = icmp ult i64 %iter1.sroa.0.0, 64
  %_0.i1.i.i9 = zext i1 %_0.i.i.i5 to i64
  %iter1.sroa.0.1 = add nuw i64 %iter1.sroa.0.0, %_0.i1.i.i9
  %_0.i.i1.sroa.5.2 = select i1 %_0.i.i.i5, i64 %iter1.sroa.0.0, i64 %_0.i.i1.sroa.5.1
  br i1 %_0.i.i.i5, label %bb13, label %bb14

bb13:                                             ; preds = %bb11
  %_30 = shl i64 %_0.i.i.sroa.5.1, 6
  %_29 = add i64 %_30, %_0.i.i1.sroa.5.2
  %_32 = icmp ult i64 %_29, %src.1
  br i1 %_32, label %bb15, label %panic2

bb14:                                             ; preds = %bb11
  %_36 = icmp ult i64 %_0.i.i.sroa.5.1, %dst.1
  br i1 %_36, label %bb16, label %panic

bb16:                                             ; preds = %bb14
  %0 = getelementptr inbounds nuw [8 x i8], ptr %dst.0, i64 %_0.i.i.sroa.5.1
  store i64 %packed.sroa.0.0, ptr %0, align 8
  br label %bb5

panic:                                            ; preds = %bb14
  call void @_ZN4core9panicking18panic_bounds_check17h9ae613628793029fE(i64 %_0.i.i.sroa.5.1, i64 %dst.1, ptr nonnull align 8 @alloc_f0b308cc4c9df2d44f594e69a671f9e6) #5
  unreachable

bb15:                                             ; preds = %bb13
  %1 = getelementptr inbounds nuw i8, ptr %src.0, i64 %_29
  %_28 = load i8, ptr %1, align 1
  %_27 = icmp ne i8 %_28, 0
  %_26 = zext i1 %_27 to i64
  %2 = and i64 %_0.i.i1.sroa.5.2, 63
  %_25 = shl nuw i64 %_26, %2
  %3 = or i64 %packed.sroa.0.0, %_25
  br label %bb11

panic2:                                           ; preds = %bb13
  call void @_ZN4core9panicking18panic_bounds_check17h9ae613628793029fE(i64 %_29, i64 %src.1, ptr nonnull align 8 @alloc_f8b5cd2d0201c42fe0e3a94f0cc4a75a) #5
  unreachable
}

; Function Attrs: nounwind nonlazybind uwtable
define void @collect_bool_unchecked(ptr align 1 %src.0, i64 %src.1, ptr align 8 %dst.0, i64 %dst.1) unnamed_addr #1 {
start:
  %chunks18 = lshr i64 %src.1, 6
  %_6.not = icmp ult i64 %dst.1, %chunks18
  br i1 %_6.not, label %bb3, label %bb5

bb3:                                              ; preds = %start
  call void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr nonnull align 1 @alloc_6957e294861d181a0a9ce74760eb0966, i64 37, ptr nonnull align 8 @alloc_9b24b8bc0a0d53448541ad776ac7579d) #5
  unreachable

bb5:                                              ; preds = %start, %bb14
  %_0.i.i.sroa.5.0 = phi i64 [ %_0.i.i.sroa.5.1, %bb14 ], [ undef, %start ]
  %_0.i.i1.sroa.5.0 = phi i64 [ %_0.i.i1.sroa.5.2, %bb14 ], [ undef, %start ]
  %iter.sroa.0.0 = phi i64 [ %iter.sroa.0.1, %bb14 ], [ 0, %start ]
  %_0.i.i.i = icmp ult i64 %iter.sroa.0.0, %chunks18
  %_0.i.i.sroa.5.1 = select i1 %_0.i.i.i, i64 %iter.sroa.0.0, i64 %_0.i.i.sroa.5.0
  %_0.i1.i.i = zext i1 %_0.i.i.i to i64
  %iter.sroa.0.1 = add nuw i64 %iter.sroa.0.0, %_0.i1.i.i
  br i1 %_0.i.i.i, label %bb11, label %bb9

bb9:                                              ; preds = %bb5
  ret void

bb11:                                             ; preds = %bb5, %bb13
  %iter1.sroa.0.0 = phi i64 [ %iter1.sroa.0.1, %bb13 ], [ 0, %bb5 ]
  %packed.sroa.0.0 = phi i64 [ %2, %bb13 ], [ 0, %bb5 ]
  %_0.i.i1.sroa.5.1 = phi i64 [ %_0.i.i1.sroa.5.2, %bb13 ], [ %_0.i.i1.sroa.5.0, %bb5 ]
  %_0.i.i.i5 = icmp samesign ult i64 %iter1.sroa.0.0, 64
  %_0.i.i1.sroa.5.2 = select i1 %_0.i.i.i5, i64 %iter1.sroa.0.0, i64 %_0.i.i1.sroa.5.1
  br i1 %_0.i.i.i5, label %bb13, label %bb14

bb13:                                             ; preds = %bb11
  %iter1.sroa.0.1 = add nuw nsw i64 %iter1.sroa.0.0, 1
  %_29 = shl i64 %_0.i.i.sroa.5.1, 6
  %0 = getelementptr i8, ptr %src.0, i64 %_29
  %_0.i.i11 = getelementptr i8, ptr %0, i64 %_0.i.i1.sroa.5.2
  %_26 = load i8, ptr %_0.i.i11, align 1
  %b = icmp ne i8 %_26, 0
  %_31 = zext i1 %b to i64
  %1 = and i64 %_0.i.i1.sroa.5.2, 63
  %_30 = shl nuw i64 %_31, %1
  %2 = or i64 %packed.sroa.0.0, %_30
  br label %bb11

bb14:                                             ; preds = %bb11
  %_0.i.i12 = getelementptr inbounds nuw [8 x i8], ptr %dst.0, i64 %_0.i.i.sroa.5.1
  store i64 %packed.sroa.0.0, ptr %_0.i.i12, align 8
  br label %bb5
}

; Function Attrs: cold noinline noreturn nounwind nonlazybind uwtable
declare void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr align 1, i64, ptr align 8) unnamed_addr #2

; Function Attrs: cold minsize noinline noreturn nounwind nonlazybind optsize uwtable
declare void @_ZN4core9panicking18panic_bounds_check17h9ae613628793029fE(i64, i64, ptr align 8) unnamed_addr #3

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #4

attributes #0 = { inlinehint nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #1 = { nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #2 = { cold noinline noreturn nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #3 = { cold minsize noinline noreturn nounwind nonlazybind optsize uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #4 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #5 = { noinline noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 2, !"RtLibUseGOT", i32 1}
!2 = !{!"rustc version 1.94.1 (e408947bf 2026-03-25)"}
