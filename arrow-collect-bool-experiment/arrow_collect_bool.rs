//! Standalone replica of arrow-rs `MutableBuffer::collect_bool`
//! (arrow-buffer/src/buffer/mutable.rs), the routine behind both
//! `Vec<bool>::into_iter().collect::<BooleanArray>()` and the
//! `arrow_ord::cmp` kernels (gt/lt/eq on primitive arrays).
//!
//! Core idiom per 64-element chunk:
//!     packed |= (f(i) as u64) << bit_idx;
#![crate_type = "lib"]

/// Case 1: collect a BooleanArray bit-buffer from a buffer of `bool`
/// (`Vec<bool> -> BooleanArray` via FromIterator / collect_bool with
/// `f = |i| src[i]`). Whole 64-bit chunks only; arrow handles the
/// remainder in a separate scalar tail.
#[no_mangle]
pub unsafe extern "C" fn collect_bool_from_bool_vec(
    src: *const bool,
    dst: *mut u64,
    chunks: usize,
) {
    for chunk in 0..chunks {
        let mut packed: u64 = 0;
        for bit_idx in 0..64usize {
            let i = chunk * 64 + bit_idx;
            packed |= (*src.add(i) as u64) << bit_idx;
        }
        *dst.add(chunk) = packed;
    }
}

/// Case 2: collect a BooleanArray bit-buffer from an i32 array through a
/// comparison (`arrow_ord::cmp::gt(array, scalar)`, i.e. collect_bool with
/// `f = |i| src[i] > k`, the icmp feeding the bit-pack).
#[no_mangle]
pub unsafe extern "C" fn collect_bool_from_i32_gt(
    src: *const i32,
    dst: *mut u64,
    chunks: usize,
    k: i32,
) {
    for chunk in 0..chunks {
        let mut packed: u64 = 0;
        for bit_idx in 0..64usize {
            let i = chunk * 64 + bit_idx;
            packed |= ((*src.add(i) > k) as u64) << bit_idx;
        }
        *dst.add(chunk) = packed;
    }
}
