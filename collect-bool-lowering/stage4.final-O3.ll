; ModuleID = 'collect_bool.O0.ll'
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
  %min.iters.check = icmp ult i64 %2, 4
  br i1 %min.iters.check, label %bb13.preheader, label %vector.ph

vector.ph:                                        ; preds = %bb8
  %umin = tail call i64 @llvm.umin.i64(i64 %2, i64 63)
  %3 = add nuw nsw i64 %umin, 1
  %n.mod.vf = and i64 %3, 3
  %4 = icmp eq i64 %n.mod.vf, 0
  %5 = select i1 %4, i64 4, i64 %n.mod.vf
  %n.vec = sub nsw i64 %3, %5
  %invariant.gep = getelementptr i8, ptr %src.0, i64 %_30
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <2 x i64> [ zeroinitializer, %vector.ph ], [ %13, %vector.body ]
  %vec.phi30 = phi <2 x i64> [ zeroinitializer, %vector.ph ], [ %14, %vector.body ]
  %vec.ind = phi <2 x i64> [ <i64 0, i64 1>, %vector.ph ], [ %vec.ind.next, %vector.body ]
  %step.add = add nuw <2 x i64> %vec.ind, splat (i64 2)
  %gep = getelementptr i8, ptr %invariant.gep, i64 %index
  %6 = getelementptr inbounds nuw i8, ptr %gep, i64 2
  %wide.load = load <2 x i8>, ptr %gep, align 1
  %wide.load31 = load <2 x i8>, ptr %6, align 1
  %7 = icmp ne <2 x i8> %wide.load, zeroinitializer
  %8 = icmp ne <2 x i8> %wide.load31, zeroinitializer
  %9 = zext <2 x i1> %7 to <2 x i64>
  %10 = zext <2 x i1> %8 to <2 x i64>
  %11 = shl nuw <2 x i64> %9, %vec.ind
  %12 = shl nuw <2 x i64> %10, %step.add
  %13 = or <2 x i64> %11, %vec.phi
  %14 = or <2 x i64> %12, %vec.phi30
  %index.next = add nuw i64 %index, 4
  %vec.ind.next = add nuw <2 x i64> %vec.ind, splat (i64 4)
  %15 = icmp eq i64 %index.next, %n.vec
  br i1 %15, label %middle.block, label %vector.body, !llvm.loop !3

middle.block:                                     ; preds = %vector.body
  %bin.rdx = or <2 x i64> %14, %13
  %16 = tail call i64 @llvm.vector.reduce.or.v2i64(<2 x i64> %bin.rdx)
  br label %bb13.preheader

bb13.preheader:                                   ; preds = %bb8, %middle.block
  %packed.sroa.0.023.ph = phi i64 [ 0, %bb8 ], [ %16, %middle.block ]
  %iter1.sroa.0.022.ph = phi i64 [ 0, %bb8 ], [ %n.vec, %middle.block ]
  br label %bb13

bb9:                                              ; preds = %bb14, %bb5.preheader.split
  ret void

bb13:                                             ; preds = %bb13.preheader, %bb15
  %packed.sroa.0.023 = phi i64 [ %19, %bb15 ], [ %packed.sroa.0.023.ph, %bb13.preheader ]
  %iter1.sroa.0.022 = phi i64 [ %_0.i1.i.i11, %bb15 ], [ %iter1.sroa.0.022.ph, %bb13.preheader ]
  %_29 = add nuw nsw i64 %iter1.sroa.0.022, %_30
  %_32 = icmp ult i64 %_29, %src.1
  br i1 %_32, label %bb15, label %panic2

bb14:                                             ; preds = %bb15
  %17 = getelementptr inbounds nuw [8 x i8], ptr %dst.0, i64 %iter.sroa.0.025
  store i64 %19, ptr %17, align 8
  %exitcond27.not = icmp eq i64 %_0.i1.i.i, %chunks4
  br i1 %exitcond27.not, label %bb9, label %bb8

bb15:                                             ; preds = %bb13
  %_0.i1.i.i11 = add nuw nsw i64 %iter1.sroa.0.022, 1
  %18 = getelementptr inbounds nuw i8, ptr %src.0, i64 %_29
  %_28 = load i8, ptr %18, align 1
  %_27 = icmp ne i8 %_28, 0
  %_26 = zext i1 %_27 to i64
  %_25 = shl nuw i64 %_26, %iter1.sroa.0.022
  %19 = or i64 %_25, %packed.sroa.0.023
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

bb8:                                              ; preds = %bb5.preheader, %bb14
  %iter.sroa.0.023 = phi i64 [ %_0.i1.i.i, %bb14 ], [ 0, %bb5.preheader ]
  %_29 = shl i64 %iter.sroa.0.023, 6
  %0 = getelementptr inbounds nuw i8, ptr %src.0, i64 %_29
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %bb8
  %index = phi i64 [ 0, %bb8 ], [ %index.next, %vector.body ]
  %vec.phi = phi <2 x i64> [ zeroinitializer, %bb8 ], [ %9, %vector.body ]
  %vec.phi25 = phi <2 x i64> [ zeroinitializer, %bb8 ], [ %10, %vector.body ]
  %vec.ind = phi <2 x i64> [ <i64 0, i64 1>, %bb8 ], [ %vec.ind.next, %vector.body ]
  %step.add = add nuw <2 x i64> %vec.ind, splat (i64 2)
  %1 = getelementptr inbounds nuw i8, ptr %0, i64 %index
  %2 = getelementptr inbounds nuw i8, ptr %1, i64 2
  %wide.load = load <2 x i8>, ptr %1, align 1
  %wide.load26 = load <2 x i8>, ptr %2, align 1
  %3 = icmp ne <2 x i8> %wide.load, zeroinitializer
  %4 = icmp ne <2 x i8> %wide.load26, zeroinitializer
  %5 = zext <2 x i1> %3 to <2 x i64>
  %6 = zext <2 x i1> %4 to <2 x i64>
  %7 = shl nuw <2 x i64> %5, %vec.ind
  %8 = shl nuw <2 x i64> %6, %step.add
  %9 = or <2 x i64> %7, %vec.phi
  %10 = or <2 x i64> %8, %vec.phi25
  %index.next = add nuw i64 %index, 4
  %vec.ind.next = add nuw <2 x i64> %vec.ind, splat (i64 4)
  %11 = icmp eq i64 %index.next, 64
  br i1 %11, label %bb14, label %vector.body, !llvm.loop !7

bb9:                                              ; preds = %bb14, %bb5.preheader
  ret void

bb14:                                             ; preds = %vector.body
  %bin.rdx = or <2 x i64> %10, %9
  %12 = tail call i64 @llvm.vector.reduce.or.v2i64(<2 x i64> %bin.rdx)
  %_0.i1.i.i = add nuw nsw i64 %iter.sroa.0.023, 1
  %_0.i.i13 = getelementptr inbounds nuw [8 x i8], ptr %dst.0, i64 %iter.sroa.0.023
  store i64 %12, ptr %_0.i.i13, align 8
  %exitcond24.not = icmp eq i64 %_0.i1.i.i, %chunks4
  br i1 %exitcond24.not, label %bb9, label %bb8
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
declare i64 @llvm.vector.reduce.or.v2i64(<2 x i64>) #5

attributes #0 = { inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(argmem: readwrite) uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #1 = { inlinehint mustprogress nofree norecurse nosync nounwind nonlazybind willreturn memory(none) uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #2 = { nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #3 = { cold noinline noreturn nounwind nonlazybind uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
attributes #4 = { cold minsize noinline noreturn nounwind nonlazybind optsize uwtable "probe-stack"="inline-asm" "target-cpu"="x86-64" }
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
!7 = distinct !{!7, !4, !5}
