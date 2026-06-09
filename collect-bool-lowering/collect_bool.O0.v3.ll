; ModuleID = 'collect_bool.b8286983fdd6b685-cgu.0'
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

; <usize as core::iter::range::Step>::forward_unchecked
; Function Attrs: inlinehint nounwind nonlazybind uwtable
define internal i64 @"_ZN49_$LT$usize$u20$as$u20$core..iter..range..Step$GT$17forward_unchecked17h3b665c3bd2e6c802E"(i64 %start1, i64 %n) unnamed_addr #0 {
start:
  br label %bb2

bb2:                                              ; preds = %start
  %_0 = add nuw i64 %start1, %n
  ret i64 %_0

bb1:                                              ; No predecessors!
  unreachable
}

; core::iter::range::<impl core::iter::traits::iterator::Iterator for core::ops::range::Range<A>>::next
; Function Attrs: inlinehint nounwind nonlazybind uwtable
define { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17h52a5946471487a67E"(ptr align 8 %self) unnamed_addr #0 {
start:
; call <core::ops::range::Range<T> as core::iter::range::RangeIteratorImpl>::spec_next
  %0 = call { i64, i64 } @"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h9fce37053dc85e9eE"(ptr align 8 %self) #4
  %_0.0 = extractvalue { i64, i64 } %0, 0
  %_0.1 = extractvalue { i64, i64 } %0, 1
  %1 = insertvalue { i64, i64 } poison, i64 %_0.0, 0
  %2 = insertvalue { i64, i64 } %1, i64 %_0.1, 1
  ret { i64, i64 } %2
}

; core::slice::<impl [T]>::get_unchecked
; Function Attrs: inlinehint nounwind nonlazybind uwtable
define align 1 ptr @"_ZN4core5slice29_$LT$impl$u20$$u5b$T$u5d$$GT$13get_unchecked17hc0fc15b0f52b5203E"(ptr align 1 %self.0, i64 %self.1, i64 %index, ptr align 8 %0) unnamed_addr #0 {
start:
; call <usize as core::slice::index::SliceIndex<[T]>>::get_unchecked
  %_3 = call ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$13get_unchecked17h6403856dd64b9aa4E"(i64 %index, ptr %self.0, i64 %self.1, ptr align 8 %0) #4
  ret ptr %_3
}

; core::slice::<impl [T]>::get_unchecked_mut
; Function Attrs: inlinehint nounwind nonlazybind uwtable
define align 8 ptr @"_ZN4core5slice29_$LT$impl$u20$$u5b$T$u5d$$GT$17get_unchecked_mut17h342d343e67607f02E"(ptr align 8 %self.0, i64 %self.1, i64 %index, ptr align 8 %0) unnamed_addr #0 {
start:
; call <usize as core::slice::index::SliceIndex<[T]>>::get_unchecked_mut
  %_3 = call ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$17get_unchecked_mut17hc032a06ca74226baE"(i64 %index, ptr %self.0, i64 %self.1, ptr align 8 %0) #4
  ret ptr %_3
}

; <I as core::iter::traits::collect::IntoIterator>::into_iter
; Function Attrs: inlinehint nounwind nonlazybind uwtable
define { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h7832bcb16f94822eE"(i64 %self.0, i64 %self.1) unnamed_addr #0 {
start:
  %0 = insertvalue { i64, i64 } poison, i64 %self.0, 0
  %1 = insertvalue { i64, i64 } %0, i64 %self.1, 1
  ret { i64, i64 } %1
}

; <usize as core::slice::index::SliceIndex<[T]>>::get_unchecked
; Function Attrs: inlinehint nounwind nonlazybind uwtable
define ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$13get_unchecked17h6403856dd64b9aa4E"(i64 %self, ptr %slice.0, i64 %slice.1, ptr align 8 %0) unnamed_addr #0 {
start:
  br label %bb3

bb3:                                              ; preds = %start
  %_5 = icmp ult i64 %self, %slice.1
  %_0 = getelementptr inbounds nuw i8, ptr %slice.0, i64 %self
  ret ptr %_0

bb1:                                              ; No predecessors!
  unreachable

bb2:                                              ; No predecessors!
  unreachable
}

; <usize as core::slice::index::SliceIndex<[T]>>::get_unchecked_mut
; Function Attrs: inlinehint nounwind nonlazybind uwtable
define ptr @"_ZN75_$LT$usize$u20$as$u20$core..slice..index..SliceIndex$LT$$u5b$T$u5d$$GT$$GT$17get_unchecked_mut17hc032a06ca74226baE"(i64 %self, ptr %slice.0, i64 %slice.1, ptr align 8 %0) unnamed_addr #0 {
start:
  br label %bb3

bb3:                                              ; preds = %start
  %_0 = getelementptr inbounds nuw i64, ptr %slice.0, i64 %self
  ret ptr %_0

bb1:                                              ; No predecessors!
  unreachable

bb2:                                              ; No predecessors!
  unreachable
}

; <core::ops::range::Range<T> as core::iter::range::RangeIteratorImpl>::spec_next
; Function Attrs: inlinehint nounwind nonlazybind uwtable
define { i64, i64 } @"_ZN89_$LT$core..ops..range..Range$LT$T$GT$$u20$as$u20$core..iter..range..RangeIteratorImpl$GT$9spec_next17h9fce37053dc85e9eE"(ptr align 8 %self) unnamed_addr #0 {
start:
  %_0 = alloca [16 x i8], align 8
  %_4 = getelementptr inbounds i8, ptr %self, i64 8
  %_3.i = load i64, ptr %self, align 8
  %_4.i = load i64, ptr %_4, align 8
  %_0.i = icmp ult i64 %_3.i, %_4.i
  br i1 %_0.i, label %bb2, label %bb4

bb4:                                              ; preds = %start
  store i64 0, ptr %_0, align 8
  br label %bb5

bb2:                                              ; preds = %start
  %old = load i64, ptr %self, align 8
; call <usize as core::iter::range::Step>::forward_unchecked
  %_6 = call i64 @"_ZN49_$LT$usize$u20$as$u20$core..iter..range..Step$GT$17forward_unchecked17h3b665c3bd2e6c802E"(i64 %old, i64 1) #4
  store i64 %_6, ptr %self, align 8
  %0 = getelementptr inbounds i8, ptr %_0, i64 8
  store i64 %old, ptr %0, align 8
  store i64 1, ptr %_0, align 8
  br label %bb5

bb5:                                              ; preds = %bb2, %bb4
  %1 = load i64, ptr %_0, align 8
  %2 = getelementptr inbounds i8, ptr %_0, i64 8
  %3 = load i64, ptr %2, align 8
  %4 = insertvalue { i64, i64 } poison, i64 %1, 0
  %5 = insertvalue { i64, i64 } %4, i64 %3, 1
  ret { i64, i64 } %5
}

; Function Attrs: nounwind nonlazybind uwtable
define void @collect_bool(ptr align 1 %src.0, i64 %src.1, ptr align 8 %dst.0, i64 %dst.1) unnamed_addr #1 {
start:
  %_21 = alloca [16 x i8], align 8
  %iter1 = alloca [16 x i8], align 8
  %packed = alloca [8 x i8], align 8
  %_13 = alloca [16 x i8], align 8
  %iter = alloca [16 x i8], align 8
  %chunks = udiv i64 %src.1, 64
  %_6 = icmp uge i64 %dst.1, %chunks
  br i1 %_6, label %bb2, label %bb3

bb3:                                              ; preds = %start
; call core::panicking::panic
  call void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr align 1 @alloc_6957e294861d181a0a9ce74760eb0966, i64 37, ptr align 8 @alloc_74638943da2922824d60629cbfb02232) #5
  unreachable

bb2:                                              ; preds = %start
; call <I as core::iter::traits::collect::IntoIterator>::into_iter
  %0 = call { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h7832bcb16f94822eE"(i64 0, i64 %chunks) #4
  %_10.0 = extractvalue { i64, i64 } %0, 0
  %_10.1 = extractvalue { i64, i64 } %0, 1
  store i64 %_10.0, ptr %iter, align 8
  %1 = getelementptr inbounds i8, ptr %iter, i64 8
  store i64 %_10.1, ptr %1, align 8
  br label %bb5

bb5:                                              ; preds = %bb16, %bb2
; call core::iter::range::<impl core::iter::traits::iterator::Iterator for core::ops::range::Range<A>>::next
  %2 = call { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17h52a5946471487a67E"(ptr align 8 %iter) #4
  %3 = extractvalue { i64, i64 } %2, 0
  %4 = extractvalue { i64, i64 } %2, 1
  store i64 %3, ptr %_13, align 8
  %5 = getelementptr inbounds i8, ptr %_13, i64 8
  store i64 %4, ptr %5, align 8
  %_15 = load i64, ptr %_13, align 8
  %6 = getelementptr inbounds i8, ptr %_13, i64 8
  %7 = load i64, ptr %6, align 8
  %8 = trunc nuw i64 %_15 to i1
  br i1 %8, label %bb8, label %bb9

bb8:                                              ; preds = %bb5
  %9 = getelementptr inbounds i8, ptr %_13, i64 8
  %chunk = load i64, ptr %9, align 8
  store i64 0, ptr %packed, align 8
; call <I as core::iter::traits::collect::IntoIterator>::into_iter
  %10 = call { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h7832bcb16f94822eE"(i64 0, i64 64) #4
  %_18.0 = extractvalue { i64, i64 } %10, 0
  %_18.1 = extractvalue { i64, i64 } %10, 1
  store i64 %_18.0, ptr %iter1, align 8
  %11 = getelementptr inbounds i8, ptr %iter1, i64 8
  store i64 %_18.1, ptr %11, align 8
  br label %bb11

bb9:                                              ; preds = %bb5
  ret void

bb11:                                             ; preds = %bb15, %bb8
; call core::iter::range::<impl core::iter::traits::iterator::Iterator for core::ops::range::Range<A>>::next
  %12 = call { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17h52a5946471487a67E"(ptr align 8 %iter1) #4
  %13 = extractvalue { i64, i64 } %12, 0
  %14 = extractvalue { i64, i64 } %12, 1
  store i64 %13, ptr %_21, align 8
  %15 = getelementptr inbounds i8, ptr %_21, i64 8
  store i64 %14, ptr %15, align 8
  %_23 = load i64, ptr %_21, align 8
  %16 = getelementptr inbounds i8, ptr %_21, i64 8
  %17 = load i64, ptr %16, align 8
  %18 = trunc nuw i64 %_23 to i1
  br i1 %18, label %bb13, label %bb14

bb13:                                             ; preds = %bb11
  %19 = getelementptr inbounds i8, ptr %_21, i64 8
  %bit_idx = load i64, ptr %19, align 8
  %_30 = mul i64 %chunk, 64
  %_29 = add i64 %_30, %bit_idx
  %_32 = icmp ult i64 %_29, %src.1
  br i1 %_32, label %bb15, label %panic2

bb14:                                             ; preds = %bb11
  %_33 = load i64, ptr %packed, align 8
  %_36 = icmp ult i64 %chunk, %dst.1
  br i1 %_36, label %bb16, label %panic

bb16:                                             ; preds = %bb14
  %20 = getelementptr inbounds nuw i64, ptr %dst.0, i64 %chunk
  store i64 %_33, ptr %20, align 8
  br label %bb5

panic:                                            ; preds = %bb14
; call core::panicking::panic_bounds_check
  call void @_ZN4core9panicking18panic_bounds_check17h9ae613628793029fE(i64 %chunk, i64 %dst.1, ptr align 8 @alloc_f0b308cc4c9df2d44f594e69a671f9e6) #5
  unreachable

bb15:                                             ; preds = %bb13
  %21 = getelementptr inbounds nuw i8, ptr %src.0, i64 %_29
  %_28 = load i8, ptr %21, align 1
  %_27 = icmp ne i8 %_28, 0
  %_26 = zext i1 %_27 to i64
  %22 = and i64 %bit_idx, 63
  %_25 = shl i64 %_26, %22
  %23 = load i64, ptr %packed, align 8
  %24 = or i64 %23, %_25
  store i64 %24, ptr %packed, align 8
  br label %bb11

panic2:                                           ; preds = %bb13
; call core::panicking::panic_bounds_check
  call void @_ZN4core9panicking18panic_bounds_check17h9ae613628793029fE(i64 %_29, i64 %src.1, ptr align 8 @alloc_f8b5cd2d0201c42fe0e3a94f0cc4a75a) #5
  unreachable

bb7:                                              ; No predecessors!
  unreachable
}

; Function Attrs: nounwind nonlazybind uwtable
define void @collect_bool_unchecked(ptr align 1 %src.0, i64 %src.1, ptr align 8 %dst.0, i64 %dst.1) unnamed_addr #1 {
start:
  %_21 = alloca [16 x i8], align 8
  %iter1 = alloca [16 x i8], align 8
  %packed = alloca [8 x i8], align 8
  %_13 = alloca [16 x i8], align 8
  %iter = alloca [16 x i8], align 8
  %chunks = udiv i64 %src.1, 64
  %_6 = icmp uge i64 %dst.1, %chunks
  br i1 %_6, label %bb2, label %bb3

bb3:                                              ; preds = %start
; call core::panicking::panic
  call void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr align 1 @alloc_6957e294861d181a0a9ce74760eb0966, i64 37, ptr align 8 @alloc_9b24b8bc0a0d53448541ad776ac7579d) #5
  unreachable

bb2:                                              ; preds = %start
; call <I as core::iter::traits::collect::IntoIterator>::into_iter
  %0 = call { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h7832bcb16f94822eE"(i64 0, i64 %chunks) #4
  %_10.0 = extractvalue { i64, i64 } %0, 0
  %_10.1 = extractvalue { i64, i64 } %0, 1
  store i64 %_10.0, ptr %iter, align 8
  %1 = getelementptr inbounds i8, ptr %iter, i64 8
  store i64 %_10.1, ptr %1, align 8
  br label %bb5

bb5:                                              ; preds = %bb14, %bb2
; call core::iter::range::<impl core::iter::traits::iterator::Iterator for core::ops::range::Range<A>>::next
  %2 = call { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17h52a5946471487a67E"(ptr align 8 %iter) #4
  %3 = extractvalue { i64, i64 } %2, 0
  %4 = extractvalue { i64, i64 } %2, 1
  store i64 %3, ptr %_13, align 8
  %5 = getelementptr inbounds i8, ptr %_13, i64 8
  store i64 %4, ptr %5, align 8
  %_15 = load i64, ptr %_13, align 8
  %6 = getelementptr inbounds i8, ptr %_13, i64 8
  %7 = load i64, ptr %6, align 8
  %8 = trunc nuw i64 %_15 to i1
  br i1 %8, label %bb8, label %bb9

bb8:                                              ; preds = %bb5
  %9 = getelementptr inbounds i8, ptr %_13, i64 8
  %chunk = load i64, ptr %9, align 8
  store i64 0, ptr %packed, align 8
; call <I as core::iter::traits::collect::IntoIterator>::into_iter
  %10 = call { i64, i64 } @"_ZN63_$LT$I$u20$as$u20$core..iter..traits..collect..IntoIterator$GT$9into_iter17h7832bcb16f94822eE"(i64 0, i64 64) #4
  %_18.0 = extractvalue { i64, i64 } %10, 0
  %_18.1 = extractvalue { i64, i64 } %10, 1
  store i64 %_18.0, ptr %iter1, align 8
  %11 = getelementptr inbounds i8, ptr %iter1, i64 8
  store i64 %_18.1, ptr %11, align 8
  br label %bb11

bb9:                                              ; preds = %bb5
  ret void

bb11:                                             ; preds = %bb13, %bb8
; call core::iter::range::<impl core::iter::traits::iterator::Iterator for core::ops::range::Range<A>>::next
  %12 = call { i64, i64 } @"_ZN4core4iter5range101_$LT$impl$u20$core..iter..traits..iterator..Iterator$u20$for$u20$core..ops..range..Range$LT$A$GT$$GT$4next17h52a5946471487a67E"(ptr align 8 %iter1) #4
  %13 = extractvalue { i64, i64 } %12, 0
  %14 = extractvalue { i64, i64 } %12, 1
  store i64 %13, ptr %_21, align 8
  %15 = getelementptr inbounds i8, ptr %_21, i64 8
  store i64 %14, ptr %15, align 8
  %_23 = load i64, ptr %_21, align 8
  %16 = getelementptr inbounds i8, ptr %_21, i64 8
  %17 = load i64, ptr %16, align 8
  %18 = trunc nuw i64 %_23 to i1
  br i1 %18, label %bb13, label %bb14

bb13:                                             ; preds = %bb11
  %19 = getelementptr inbounds i8, ptr %_21, i64 8
  %bit_idx = load i64, ptr %19, align 8
  %_29 = mul i64 %chunk, 64
  %_28 = add i64 %_29, %bit_idx
; call core::slice::<impl [T]>::get_unchecked
  %_27 = call align 1 ptr @"_ZN4core5slice29_$LT$impl$u20$$u5b$T$u5d$$GT$13get_unchecked17hc0fc15b0f52b5203E"(ptr align 1 %src.0, i64 %src.1, i64 %_28, ptr align 8 @alloc_82f6be90851d0bc80aedf62cb9e353c9) #4
  %_26 = load i8, ptr %_27, align 1
  %b = icmp ne i8 %_26, 0
  %_31 = zext i1 %b to i64
  %20 = and i64 %bit_idx, 63
  %_30 = shl i64 %_31, %20
  %21 = load i64, ptr %packed, align 8
  %22 = or i64 %21, %_30
  store i64 %22, ptr %packed, align 8
  br label %bb11

bb14:                                             ; preds = %bb11
  %_32 = load i64, ptr %packed, align 8
; call core::slice::<impl [T]>::get_unchecked_mut
  %_33 = call align 8 ptr @"_ZN4core5slice29_$LT$impl$u20$$u5b$T$u5d$$GT$17get_unchecked_mut17h342d343e67607f02E"(ptr align 8 %dst.0, i64 %dst.1, i64 %chunk, ptr align 8 @alloc_223f5ea3b707359a7bb835948d11137a) #4
  store i64 %_32, ptr %_33, align 8
  br label %bb5

bb7:                                              ; No predecessors!
  unreachable
}

; core::panicking::panic
; Function Attrs: cold noinline noreturn nounwind nonlazybind uwtable
declare void @_ZN4core9panicking5panic17h8bbbe005ba322b34E(ptr align 1, i64, ptr align 8) unnamed_addr #2

; core::panicking::panic_bounds_check
; Function Attrs: cold minsize noinline noreturn nounwind nonlazybind optsize uwtable
declare void @_ZN4core9panicking18panic_bounds_check17h9ae613628793029fE(i64, i64, ptr align 8) unnamed_addr #3

attributes #0 = { inlinehint nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #1 = { nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #2 = { cold noinline noreturn nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #3 = { cold minsize noinline noreturn nounwind nonlazybind optsize uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64-v3" }
attributes #4 = { inlinehint nounwind }
attributes #5 = { noinline noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 2, !"RtLibUseGOT", i32 1}
!2 = !{!"rustc version 1.94.1 (e408947bf 2026-03-25)"}
