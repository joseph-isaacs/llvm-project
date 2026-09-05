//! Hunt 2, batch B: scalar paths not exercised by the nine findings.
//! Targets: DAG division-by-constant, i128/u128 legalisation, float ISel, enum niche/tag tests,
//! ABI/return-value shaping, string parsing, devirtualisation. Comments say what good output is.
use std::num::NonZeroU32;

// --- division / remainder by constants (DAGCombine magic numbers) ---
#[no_mangle] pub fn div10(x: u32) -> u32 { x / 10 }
#[no_mangle] pub fn div10_i(x: i32) -> i32 { x / 10 }
#[no_mangle] pub fn div1000_u64(x: u64) -> u64 { x / 1000 }
#[no_mangle] pub fn div7_u128(x: u128) -> u128 { x / 7 }                       // libcall __udivti3? could be mul-shift
#[no_mangle] pub fn rem10_u128(x: u128) -> u128 { x % 10 }
#[no_mangle] pub fn divrem10(x: u32) -> (u32, u32) { (x / 10, x % 10) }         // one mul, one lea
#[no_mangle] pub fn div_pow2_i(x: i32) -> i32 { x / 8 }
#[no_mangle] pub fn rem_pow2_i(x: i32) -> i32 { x % 8 }
#[no_mangle] pub fn is_mult3(x: u32) -> bool { x % 3 == 0 }                    // mul + cmp trick
#[no_mangle] pub fn is_mult10(x: u64) -> bool { x % 10 == 0 }
#[no_mangle] pub fn div_ceil10(x: u32) -> u32 { x.div_ceil(10) }
#[no_mangle] pub fn digits10(x: u64) -> u32 { x.checked_ilog10().map_or(1, |d| d + 1) }
#[no_mangle] pub fn div_by_shift_var(x: u32, s: u32) -> u32 { x / (1 << s) }    // should be shr
#[no_mangle] pub fn mul_by_var_pow2(x: u32, s: u32) -> u32 { x * (1 << s) }
#[no_mangle] pub fn mulhi_u64(a: u64, b: u64) -> u64 { ((a as u128 * b as u128) >> 64) as u64 }
#[no_mangle] pub fn mulhi_i64(a: i64, b: i64) -> i64 { ((a as i128 * b as i128) >> 64) as i64 }
#[no_mangle] pub fn u128_shl(x: u128, s: u32) -> u128 { x << (s & 127) }
#[no_mangle] pub fn u128_add_carry(a: u128, b: u128) -> (u128, bool) { a.overflowing_add(b) }
#[no_mangle] pub fn u128_cmp(a: u128, b: u128) -> std::cmp::Ordering { a.cmp(&b) }
#[no_mangle] pub fn u128_eq0(a: u128) -> bool { a == 0 }
#[no_mangle] pub fn u128_lz(a: u128) -> u32 { a.leading_zeros() }
#[no_mangle] pub fn u128_pop(a: u128) -> u32 { a.count_ones() }
#[no_mangle] pub fn u128_bswap(a: u128) -> u128 { a.swap_bytes() }
#[no_mangle] pub fn i128_abs(a: i128) -> i128 { a.wrapping_abs() }

// --- float ISel ---
#[no_mangle] pub fn f_round(x: f32) -> f32 { x.round() }                         // libcall vs vroundss
#[no_mangle] pub fn f_round_even(x: f32) -> f32 { x.round_ties_even() }         // vroundss $8
#[no_mangle] pub fn f_trunc_i(x: f32) -> i32 { x.trunc() as i32 }               // cvttss2si + saturation
#[no_mangle] pub fn f_floor_i(x: f64) -> i64 { x.floor() as i64 }
#[no_mangle] pub fn f_mul_add(a: f32, b: f32, c: f32) -> f32 { a.mul_add(b, c) } // vfmadd on v3
#[no_mangle] pub fn f_powi(x: f32) -> f32 { x.powi(3) }                          // x*x*x
#[no_mangle] pub fn f_powi5(x: f64) -> f64 { x.powi(5) }
#[no_mangle] pub fn f_sqrt_chk(x: f64) -> f64 { if x >= 0.0 { x.sqrt() } else { 0.0 } }
#[no_mangle] pub fn f_hypot(a: f32, b: f32) -> f32 { (a * a + b * b).sqrt() }
#[no_mangle] pub fn f_copysign(a: f32, b: f32) -> f32 { a.copysign(b) }
#[no_mangle] pub fn f_abs_lt(a: f32) -> bool { a.abs() < 1.0 }
#[no_mangle] pub fn f_signum(a: f32) -> f32 { a.signum() }
#[no_mangle] pub fn f_is_int(a: f64) -> bool { a == a.trunc() }
#[no_mangle] pub fn f_frac(a: f64) -> f64 { a - a.trunc() }
#[no_mangle] pub fn f_to_bits_sign(a: f32) -> bool { a.to_bits() >> 31 == 1 }   // vs a.is_sign_negative()
#[no_mangle] pub fn f_neg0(a: f32) -> bool { a == 0.0 && a.is_sign_negative() }
#[no_mangle] pub fn f_min_max_clamp(a: f32, lo: f32, hi: f32) -> f32 { a.max(lo).min(hi) }
#[no_mangle] pub fn f_lerp(a: f32, b: f32, t: f32) -> f32 { a + (b - a) * t }
#[no_mangle] pub fn f_u8_norm(x: u8) -> f32 { x as f32 / 255.0 }               // mul by reciprocal not allowed; check cvt
#[no_mangle] pub fn f_from_u64(x: u64) -> f32 { x as f32 }                       // needs rounding fixup on x86 without AVX-512
#[no_mangle] pub fn f_from_u32(x: u32) -> f64 { x as f64 }
#[no_mangle] pub fn f_from_u8(x: u8) -> f32 { x as f32 }
#[no_mangle] pub fn f_total_cmp_sort2(a: f32, b: f32) -> (f32, f32) { if a.total_cmp(&b).is_le() { (a, b) } else { (b, a) } }
#[no_mangle] pub fn f16_bits_to_f32(h: u16) -> f32 { f32::from_bits(((h as u32 & 0x8000) << 16) | (((h as u32 & 0x7c00) + 0x1c000) << 13) | ((h as u32 & 0x03ff) << 13)) }

// --- enum layout / niches / tag tests ---
#[derive(Clone, Copy, PartialEq)] #[repr(u8)] pub enum Color { R = 1, G = 2, B = 3 }
#[no_mangle] pub fn color_from_u8(x: u8) -> Option<Color> { match x { 1 => Some(Color::R), 2 => Some(Color::G), 3 => Some(Color::B), _ => None } } // should be range check + identity
#[no_mangle] pub fn color_to_u8(c: Option<Color>) -> u8 { c.map_or(0, |c| c as u8) }      // identity
#[no_mangle] pub fn color_next(c: Color) -> Color { match c { Color::R => Color::G, Color::G => Color::B, Color::B => Color::R } }
#[no_mangle] pub fn opt_opt_bool(x: Option<Option<bool>>) -> u8 { match x { None => 0, Some(None) => 1, Some(Some(false)) => 2, Some(Some(true)) => 3 } }
#[no_mangle] pub fn opt_nz_or(a: Option<NonZeroU32>, b: Option<NonZeroU32>) -> Option<NonZeroU32> { a.or(b) }   // cmov
#[no_mangle] pub fn opt_nz_map(a: Option<NonZeroU32>) -> u32 { a.map_or(0, |n| n.get() + 1) }
#[no_mangle] pub fn opt_ref_is_some(a: Option<&u32>) -> bool { a.is_some() }
#[no_mangle] pub fn opt_ref_unwrap_or(a: Option<&u32>, d: &u32) -> u32 { *a.unwrap_or(d) }
#[no_mangle] pub fn res_unit_box(r: Result<(), Box<u32>>) -> bool { r.is_ok() }
#[no_mangle] pub fn res_u32_u8(r: Result<u32, u8>) -> u32 { r.unwrap_or(0) }
pub enum E3 { A(u32), B(u32), C(u32) }
#[no_mangle] pub fn e3_payload(e: &E3) -> u32 { match e { E3::A(x) | E3::B(x) | E3::C(x) => *x } }   // payload at same offset: no branch
#[no_mangle] pub fn e3_is_a_or_b(e: &E3) -> bool { matches!(e, E3::A(_) | E3::B(_)) }
pub enum E4 { A, B(u8), C(u16), D(u32) }
#[no_mangle] pub fn e4_size(e: &E4) -> u8 { match e { E4::A => 0, E4::B(_) => 1, E4::C(_) => 2, E4::D(_) => 4 } } // lookup table or shift
#[no_mangle] pub fn e4_val(e: &E4) -> u32 { match e { E4::A => 0, E4::B(x) => *x as u32, E4::C(x) => *x as u32, E4::D(x) => *x } }
#[no_mangle] pub fn ord_opt_max(a: Option<u8>, b: Option<u8>) -> Option<u8> { a.max(b) }

// --- ABI / return shaping ---
#[no_mangle] pub fn ret_arr16(a: &[u8; 16]) -> [u8; 16] { let mut r = *a; r.reverse(); r }        // pshufb, sret
#[no_mangle] pub fn ret_opt_arr(a: &[u8], n: usize) -> Option<[u8; 8]> { a.get(n..n + 8)?.try_into().ok() } // one unaligned load
#[no_mangle] pub fn ret_pair_u8(x: u16) -> (u8, u8) { (x as u8, (x >> 8) as u8) }                  // identity
#[no_mangle] pub fn ret_tuple3(x: u32) -> (u8, u8, u8) { ((x >> 16) as u8, (x >> 8) as u8, x as u8) }
#[no_mangle] pub fn pass_arr4(a: [u8; 4]) -> u32 { u32::from_le_bytes(a) }                          // identity
#[no_mangle] pub fn pass_arr3(a: [u8; 3]) -> u32 { a[0] as u32 | (a[1] as u32) << 8 | (a[2] as u32) << 16 }
#[no_mangle] pub fn pass_opt_f32(a: Option<f32>) -> f32 { a.unwrap_or(0.0) }
#[no_mangle] pub fn swap_halves(x: u64) -> u64 { x.rotate_left(32) }

// --- strings / parsing ---
#[no_mangle] pub fn parse_u8_dec(s: &[u8]) -> Option<u8> { let mut v: u8 = 0; for &c in s { v = v.checked_mul(10)?.checked_add(c.checked_sub(b'0').filter(|&d| d < 10)?)?; } Some(v) }
#[no_mangle] pub fn parse_u32_std(s: &str) -> Option<u32> { s.parse().ok() }
#[no_mangle] pub fn starts_with_const(s: &[u8]) -> bool { s.starts_with(b"GET ") }               // one 4-byte compare
#[no_mangle] pub fn eq_const8(s: &[u8]) -> bool { s == b"abcdefgh" }
#[no_mangle] pub fn eq_ic_slice(a: &[u8], b: &[u8]) -> bool { a.eq_ignore_ascii_case(b) }
#[no_mangle] pub fn count_commas(s: &[u8]) -> usize { s.iter().filter(|&&c| c == b',').count() }
#[no_mangle] pub fn split_count(s: &str) -> usize { s.split(',').count() }
#[no_mangle] pub fn trim_start_spaces(s: &[u8]) -> &[u8] { let n = s.iter().take_while(|&&c| c == b' ').count(); &s[n..] }
#[no_mangle] pub fn hex_encode(b: &[u8; 4], out: &mut [u8; 8]) { const H: &[u8; 16] = b"0123456789abcdef"; for i in 0..4 { out[2 * i] = H[(b[i] >> 4) as usize]; out[2 * i + 1] = H[(b[i] & 15) as usize]; } }
#[no_mangle] pub fn utf8_char_len_first(s: &str) -> usize { s.chars().next().map_or(0, |c| c.len_utf8()) }

// --- devirtualisation / closures ---
pub trait Op { fn run(&self, x: u32) -> u32; }
pub struct Inc; impl Op for Inc { fn run(&self, x: u32) -> u32 { x + 1 } }
#[no_mangle] pub fn dyn_known(x: u32) -> u32 { let o: &dyn Op = &Inc; o.run(x) }                 // devirtualised: x + 1
#[no_mangle] pub fn dyn_loop(o: &dyn Op, a: &mut [u32]) { for x in a { *x = o.run(*x); } }        // vtable load hoisted?
#[no_mangle] pub fn closure_apply(a: &mut [u32], k: u32) { let f = |x: u32| x.wrapping_mul(k); for x in a { *x = f(*x); } }
#[no_mangle] pub fn fnptr_call(f: fn(u32) -> u32, x: u32) -> u32 { f(x) + f(x) }                  // two calls (no attributes)
#[no_mangle] pub fn generic_sum<I: Iterator<Item = u32>>(it: I) -> u32 { it.sum() }
#[no_mangle] pub fn boxed_slice_sum(b: &Box<[u32]>) -> u32 { b.iter().sum() }
