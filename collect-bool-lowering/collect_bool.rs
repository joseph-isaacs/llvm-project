//! Standalone model of arrow-rs `MutableBuffer::collect_bool(len, f)`,
//! specialized to the common kernel shape `collect_bool(len, |i| src[i] != 0)`:
//! bit-packing a large `u8` boolean array (one 0/1 byte per element) into a
//! bitset of `u64` words. Bit `b` of `dst[chunk]` = (src[chunk*64 + b] != 0).
//!
//! Same loop structure as arrow-rs: an outer per-word loop and an inner
//! 64-iteration packing loop `packed |= (f(i) as u64) << bit_idx`.

#[no_mangle]
pub fn collect_bool(src: &[u8], dst: &mut [u64]) {
    let chunks = src.len() / 64;
    assert!(dst.len() >= chunks);
    for chunk in 0..chunks {
        let mut packed = 0u64;
        for bit_idx in 0..64 {
            packed |= ((src[chunk * 64 + bit_idx] != 0) as u64) << bit_idx;
        }
        dst[chunk] = packed;
    }
}

/// Closer to real arrow-rs call sites, where the closure passed to
/// `collect_bool` reads without bounds checks, e.g.
/// `collect_bool(len, |i| unsafe { *src.get_unchecked(i) } != 0)`.
#[no_mangle]
pub fn collect_bool_unchecked(src: &[u8], dst: &mut [u64]) {
    let chunks = src.len() / 64;
    assert!(dst.len() >= chunks);
    for chunk in 0..chunks {
        let mut packed = 0u64;
        for bit_idx in 0..64 {
            let b = unsafe { *src.get_unchecked(chunk * 64 + bit_idx) } != 0;
            packed |= (b as u64) << bit_idx;
        }
        unsafe { *dst.get_unchecked_mut(chunk) = packed };
    }
}
