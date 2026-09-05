//! Finding 3: Mask::to_bitmask() on 2- and 4-lane masks (needs nightly).
//! Build: rustc +nightly -O -C panic=abort --crate-type=lib --emit=asm -C target-cpu=x86-64-v3 repro_simd.rs
//!        rustc +nightly -O -C panic=abort --crate-type=lib --emit=asm repro_simd.rs     (SSE2 baseline)
#![feature(portable_simd, core_intrinsics)]
use std::simd::prelude::*;
use std::intrinsics::simd::simd_bitmask;

#[no_mangle] pub fn f3_lib(v: mask64x2) -> u64 { v.to_bitmask() }
#[no_mangle] pub fn f3_direct(v: mask64x2) -> u64 { unsafe { simd_bitmask::<_, u8>(v.to_simd()) as u64 } }
#[no_mangle] pub fn f3_lib4(a: f64x4, b: f64x4) -> u64 { a.simd_lt(b).to_bitmask() }
#[no_mangle] pub fn f3_direct4(a: f64x4, b: f64x4) -> u64 { unsafe { simd_bitmask::<_, u8>(a.simd_lt(b).to_simd()) as u64 } }
#[no_mangle] pub fn f3_lib32(v: mask32x4) -> u64 { v.to_bitmask() }
#[no_mangle] pub fn f3_direct32(v: mask32x4) -> u64 { unsafe { simd_bitmask::<_, u8>(v.to_simd()) as u64 } }
