//! Differential correctness driver for hunt2: prints one hash per function over seeded random
//! inputs. Build the same file with two toolchains (or two targets) and diff the output.
#![allow(dead_code, unused_imports)]
#[path = "h_loops.rs"] mod l;
#[path = "h_scalar.rs"] mod s;
use l::*; use s::*;
use std::hint::black_box as bb;
use std::num::NonZeroU32;

struct R(u64);
impl R {
    fn n(&mut self) -> u64 { let mut x = self.0; x ^= x << 13; x ^= x >> 7; x ^= x << 17; self.0 = x; x }
    fn u32(&mut self) -> u32 { self.n() as u32 }
    fn u8(&mut self) -> u8 { self.n() as u8 }
    fn len(&mut self) -> usize { (self.n() % 40) as usize + if self.n() % 5 == 0 { (self.n() % 200) as usize } else { 0 } }
    // interesting-value biased integers
    fn w(&mut self) -> u64 { match self.n() % 8 { 0 => 0, 1 => u64::MAX, 2 => self.n() >> (self.n() % 64), 3 => 1u64 << (self.n() % 64), _ => self.n() } }
    fn w128(&mut self) -> u128 { match self.n() % 6 { 0 => 0, 1 => u128::MAX, 2 => self.w() as u128, 3 => (self.w() as u128) << 64, _ => (self.n() as u128) << 64 | self.n() as u128 } }
    fn f32(&mut self) -> f32 { match self.n() % 6 { 0 => f32::NAN, 1 => f32::INFINITY, 2 => -0.0, 3 => (self.n() % 2000) as f32 / 8.0 - 100.0, _ => f32::from_bits(self.u32()) } }
    fn f64(&mut self) -> f64 { match self.n() % 6 { 0 => f64::NAN, 1 => -f64::INFINITY, 2 => 0.0, 3 => (self.n() % 2000) as f64 / 8.0 - 100.0, _ => f64::from_bits(self.n()) } }
    fn vu8(&mut self) -> Vec<u8> { let n = self.len(); (0..n).map(|_| match self.n() % 4 { 0 => self.n() as u8 % 128, 1 => b'a' + (self.n() % 26) as u8, 2 => b'0' + (self.n() % 12) as u8, _ => self.n() as u8 }).collect() }
    fn vu32(&mut self) -> Vec<u32> { let n = self.len(); (0..n).map(|_| self.w() as u32).collect() }
    fn vu64(&mut self) -> Vec<u64> { let n = self.len(); (0..n).map(|_| self.w()).collect() }
    fn vf32(&mut self) -> Vec<f32> { let n = self.len(); (0..n).map(|_| self.f32()).collect() }
    fn s(&mut self) -> String { let n = self.len(); let mut st = String::new(); for _ in 0..n { st.push(match self.n() % 10 { 0 => ',', 1 => '+', 2 => '-', 3 => 'é', 4 => '日', 5 => '😀', 6 => ' ', _ => (b'0' + (self.n() % 10) as u8) as char }); } st }
}
struct H(u64);
impl H {
    fn b(&mut self, x: &[u8]) { for &c in x { self.0 ^= c as u64; self.0 = self.0.wrapping_mul(0x100000001b3); } }
    fn u(&mut self, x: u128) { self.b(&x.to_le_bytes()) }
    fn f(&mut self, x: f32) { self.u(if x.is_nan() { 0xfffe } else if x == 0.0 { 0 } else { x.to_bits() } as u128) }
    fn d(&mut self, x: f64) { self.u(if x.is_nan() { 0xfffe } else if x == 0.0 { 0 } else { x.to_bits() } as u128) }
}

fn main() {
    let iters: usize = std::env::args().nth(1).and_then(|a| a.parse().ok()).unwrap_or(20000);
    let mut out: Vec<(&str, u64)> = Vec::new();
    macro_rules! run { ($name:expr, |$r:ident, $h:ident| $body:block) => {{
        let mut $r = R(0x9E3779B97F4A7C15); let mut $h = H(0xcbf29ce484222325);
        for _ in 0..iters { $body }
        out.push(($name, $h.0));
    }}; }
    // ---- loops ----
    run!("fill_u8", |r, h| { let mut a = r.vu8(); let v = r.u8(); fill_u8(bb(&mut a), bb(v)); h.b(&a); });
    run!("fill_u32", |r, h| { let mut a = r.vu32(); fill_u32(bb(&mut a)); for x in &a { h.u(*x as u128) } });
    run!("fill_u32_bad", |r, h| { let mut a = r.vu32(); fill_u32_bad(bb(&mut a)); for x in &a { h.u(*x as u128) } });
    run!("copy_rev", |r, h| { let mut a = r.vu32(); let b = r.vu32(); copy_rev(bb(&mut a), bb(&b)); for x in &a { h.u(*x as u128) } });
    run!("popcnt_loop", |r, h| { let x = r.w(); h.u(popcnt_loop(bb(x)) as u128) });
    run!("popcnt_loop2", |r, h| { let x = r.w(); h.u(popcnt_loop2(bb(x)) as u128) });
    run!("clz_loop", |r, h| { let x = r.w() as u32; h.u(clz_loop(bb(x)) as u128) });
    run!("strlen_like", |r, h| { let mut a = r.vu8(); if r.n() % 2 == 0 && !a.is_empty() { let i = r.n() as usize % a.len(); a[i] = 0; } h.u(strlen_like(bb(&a)) as u128) });
    run!("find_zero_u32", |r, h| { let a = r.vu32(); h.u(find_zero_u32(bb(&a)).map_or(u64::MAX, |x| x as u64) as u128) });
    run!("sum_u8_as_u64", |r, h| { let a = r.vu8(); h.u(sum_u8_as_u64(bb(&a)) as u128) });
    run!("sum_u8_as_u32", |r, h| { let a = r.vu8(); h.u(sum_u8_as_u32(bb(&a)) as u128) });
    run!("sum_i8_as_i32", |r, h| { let a: Vec<i8> = r.vu8().into_iter().map(|x| x as i8).collect(); h.u(sum_i8_as_i32(bb(&a)) as u32 as u128) });
    run!("sat_sum_u8", |r, h| { let a = r.vu8(); h.u(sat_sum_u8(bb(&a)) as u128) });
    run!("sat_add_slices", |r, h| { let mut a = r.vu8(); let b = r.vu8(); sat_add_slices(bb(&mut a), bb(&b)); h.b(&a) });
    run!("sat_sub_slices", |r, h| { let mut a = r.vu8(); let b = r.vu8(); sat_sub_slices(bb(&mut a), bb(&b)); h.b(&a) });
    run!("wrapping_add_slices", |r, h| { let mut a = r.vu8(); let b = r.vu8(); wrapping_add_slices(bb(&mut a), bb(&b)); h.b(&a) });
    run!("abs_diff_sum", |r, h| { let a = r.vu8(); let b = r.vu8(); h.u(abs_diff_sum(bb(&a), bb(&b)) as u128) });
    run!("min_by_key_idx", |r, h| { let a = r.vu32(); h.u(min_by_key_idx(bb(&a)).map_or(u64::MAX, |x| x as u64) as u128) });
    run!("any_gt", |r, h| { let a: Vec<i32> = r.vu32().into_iter().map(|x| x as i32).collect(); let t = r.w() as i32; h.u(any_gt(bb(&a), bb(t)) as u128) });
    run!("all_in_range", |r, h| { let a = r.vu8(); h.u(all_in_range(bb(&a)) as u128) });
    run!("count_set_bits", |r, h| { let a = r.vu64(); h.u(count_set_bits(bb(&a)) as u128) });
    run!("xor_fold_u8", |r, h| { let a = r.vu8(); h.u(xor_fold_u8(bb(&a)) as u128) });
    run!("max_f32", |r, h| { let a = r.vf32(); h.f(max_f32(bb(&a))) });
    run!("max_f32_nan", |r, h| { let a = r.vf32(); h.f(max_f32_nan(bb(&a))) });
    run!("dot_f32", |r, h| { let a = r.vf32(); let b = r.vf32(); h.f(dot_f32(bb(&a), bb(&b))) });
    run!("scale_i16", |r, h| { let mut a: Vec<i16> = r.vu32().into_iter().map(|x| x as i16).collect(); let k = r.w() as i16; scale_i16(bb(&mut a), bb(k)); for x in &a { h.u(*x as u16 as u128) } });
    run!("clamp_u8", |r, h| { let mut a: Vec<i32> = r.vu32().into_iter().map(|x| x as i32).collect(); let mut o = vec![0u8; a.len()]; clamp_u8(bb(&mut a), bb(&mut o)); h.b(&o) });
    run!("bytes_to_u16", |r, h| { let a = r.vu8(); let mut o = vec![0u16; a.len()]; bytes_to_u16(bb(&a), bb(&mut o)); for x in &o { h.u(*x as u128) } });
    run!("u16_to_bytes", |r, h| { let a: Vec<u16> = r.vu32().into_iter().map(|x| x as u16).collect(); let mut o = vec![0u8; a.len()]; u16_to_bytes(bb(&a), bb(&mut o)); h.b(&o) });
    run!("bool_count", |r, h| { let a: Vec<bool> = r.vu8().into_iter().map(|x| x & 1 == 1).collect(); h.u(bool_count(bb(&a)) as u128) });
    run!("prefix_sum", |r, h| { let mut a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 12).collect(); prefix_sum(bb(&mut a)); for x in &a { h.u(*x as u128) } });
    run!("stride2_sum", |r, h| { let a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 12).collect(); h.u(stride2_sum(bb(&a)) as u128) });
    run!("rev_sum", |r, h| { let a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 12).collect(); h.u(rev_sum(bb(&a)) as u128) });
    run!("chunks4_sum", |r, h| { let a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 12).collect(); h.u(chunks4_sum(bb(&a)) as u128) });
    run!("windows2_cmp", |r, h| { let mut a = r.vu32(); if r.n() % 2 == 0 { a.sort() } h.u(windows2_cmp(bb(&a)) as u128) });
    run!("is_sorted_std", |r, h| { let mut a = r.vu32(); if r.n() % 2 == 0 { a.sort() } h.u(is_sorted_std(bb(&a)) as u128) });
    run!("enumerate_bounds", |r, h| { let a = r.vu32(); let mut b = r.vu32(); enumerate_bounds(bb(&a), bb(&mut b)); for x in &b { h.u(*x as u128) } });
    run!("zip3", |r, h| { let a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 1).collect(); let b: Vec<u32> = r.vu32().into_iter().map(|x| x >> 1).collect(); let n = a.len().min(b.len()); let mut c = vec![0u32; n]; zip3(bb(&a), bb(&b), bb(&mut c)); for x in &c { h.u(*x as u128) } });
    run!("zip3_iter", |r, h| { let a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 1).collect(); let b: Vec<u32> = r.vu32().into_iter().map(|x| x >> 1).collect(); let mut c = vec![0u32; r.len()]; zip3_iter(bb(&a), bb(&b), bb(&mut c)); for x in &c { h.u(*x as u128) } });
    run!("transpose4", |r, h| { let mut m = [[0u32; 4]; 4]; for row in &mut m { for x in row { *x = r.u32() } } transpose4(bb(&mut m)); for row in &m { for x in row { h.u(*x as u128) } } });
    run!("hist16", |r, h| { let a = r.vu8(); let mut hh = [0u32; 16]; hist16(bb(&a), bb(&mut hh)); for x in &hh { h.u(*x as u128) } });
    run!("nested_const", |r, h| { let mut a = [0u8; 64]; for x in &mut a { *x = r.u8() } nested_const(bb(&mut a)); h.b(&a) });
    run!("acc_loop", |r, h| { let a = r.vu32(); let mut acc = Acc { sum: r.w(), count: r.u32(), max: r.u32() }; acc_loop(bb(&mut acc), bb(&a)); h.u(acc.sum as u128); h.u(acc.count as u128); h.u(acc.max as u128) });
    run!("acc_loop_opt", |r, h| { let a = r.vu32(); let mut acc = if r.n() % 3 == 0 { None } else { Some(Acc { sum: r.w(), count: r.u32(), max: r.u32() }) }; acc_loop_opt(bb(&mut acc), bb(&a)); if let Some(a) = &acc { h.u(a.sum as u128); h.u(a.count as u128); h.u(a.max as u128) } else { h.u(7) } });
    run!("vec_push_loop", |r, h| { let mut v = r.vu8(); let n = r.len(); vec_push_loop(bb(&mut v), bb(n)); h.b(&v) });
    run!("vec_extend", |r, h| { let mut v = r.vu8(); let n = r.len(); vec_extend(bb(&mut v), bb(n)); h.b(&v) });
    run!("opt_take_loop", |r, h| { let mut a: Vec<Option<u32>> = r.vu32().into_iter().map(|x| if x % 3 == 0 { None } else { Some(x >> 8) }).collect(); h.u(opt_take_loop(bb(&mut a)) as u128); for x in &a { h.u(x.is_some() as u128) } });
    run!("swap_pairs", |r, h| { let mut a = r.vu32(); swap_pairs(bb(&mut a)); for x in &a { h.u(*x as u128) } });
    run!("bswap_all", |r, h| { let mut a = r.vu32(); bswap_all(bb(&mut a)); for x in &a { h.u(*x as u128) } });
    run!("shift_all", |r, h| { let mut a = r.vu32(); let s = r.u32() % 32; shift_all(bb(&mut a), bb(s)); for x in &a { h.u(*x as u128) } });
    run!("div_all", |r, h| { let mut a = r.vu32(); let d = (r.w() as u32).max(1); div_all(bb(&mut a), bb(d)); for x in &a { h.u(*x as u128) } });
    run!("mod10_all", |r, h| { let mut a = r.vu32(); mod10_all(bb(&mut a)); for x in &a { h.u(*x as u128) } });
    run!("unswitch", |r, h| { let mut a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 1).collect(); let neg = r.n() % 2 == 0; unswitch(bb(&mut a), bb(neg)); for x in &a { h.u(*x as u128) } });
    // ---- scalar ----
    run!("div10", |r, h| { h.u(div10(bb(r.w() as u32)) as u128) });
    run!("div10_i", |r, h| { h.u(div10_i(bb(r.w() as i32)) as u32 as u128) });
    run!("div1000_u64", |r, h| { h.u(div1000_u64(bb(r.w())) as u128) });
    run!("div7_u128", |r, h| { h.u(div7_u128(bb(r.w128()))) });
    run!("rem10_u128", |r, h| { h.u(rem10_u128(bb(r.w128()))) });
    run!("divrem10", |r, h| { let (a, b) = divrem10(bb(r.w() as u32)); h.u(a as u128); h.u(b as u128) });
    run!("div_pow2_i", |r, h| { h.u(div_pow2_i(bb(r.w() as i32)) as u32 as u128) });
    run!("rem_pow2_i", |r, h| { h.u(rem_pow2_i(bb(r.w() as i32)) as u32 as u128) });
    run!("is_mult3", |r, h| { h.u(is_mult3(bb(r.w() as u32)) as u128) });
    run!("is_mult10", |r, h| { h.u(is_mult10(bb(r.w())) as u128) });
    run!("div_ceil10", |r, h| { h.u(div_ceil10(bb(r.w() as u32)) as u128) });
    run!("digits10", |r, h| { h.u(digits10(bb(r.w())) as u128) });
    run!("div_by_shift_var", |r, h| { h.u(div_by_shift_var(bb(r.w() as u32), bb(r.u32() % 32)) as u128) });
    run!("mul_by_var_pow2", |r, h| { h.u(mul_by_var_pow2(bb(r.w() as u32), bb(r.u32() % 32)) as u128) });
    run!("mulhi_u64", |r, h| { h.u(mulhi_u64(bb(r.w()), bb(r.w())) as u128) });
    run!("mulhi_i64", |r, h| { h.u(mulhi_i64(bb(r.w() as i64), bb(r.w() as i64)) as u64 as u128) });
    run!("u128_shl", |r, h| { h.u(u128_shl(bb(r.w128()), bb(r.u32()))) });
    run!("u128_add_carry", |r, h| { let (a, c) = u128_add_carry(bb(r.w128()), bb(r.w128())); h.u(a); h.u(c as u128) });
    run!("u128_cmp", |r, h| { h.u(u128_cmp(bb(r.w128()), bb(r.w128())) as i8 as u8 as u128) });
    run!("u128_eq0", |r, h| { h.u(u128_eq0(bb(r.w128())) as u128) });
    run!("u128_lz", |r, h| { h.u(u128_lz(bb(r.w128())) as u128) });
    run!("u128_pop", |r, h| { h.u(u128_pop(bb(r.w128())) as u128) });
    run!("u128_bswap", |r, h| { h.u(u128_bswap(bb(r.w128()))) });
    run!("i128_abs", |r, h| { h.u(i128_abs(bb(r.w128() as i128)) as u128) });
    run!("f_round", |r, h| { h.f(f_round(bb(r.f32()))) });
    run!("f_round_even", |r, h| { h.f(f_round_even(bb(r.f32()))) });
    run!("f_trunc_i", |r, h| { h.u(f_trunc_i(bb(r.f32())) as u32 as u128) });
    run!("f_floor_i", |r, h| { h.u(f_floor_i(bb(r.f64())) as u64 as u128) });
    run!("f_mul_add", |r, h| { h.f(f_mul_add(bb(r.f32()), bb(r.f32()), bb(r.f32()))) });
    run!("f_powi", |r, h| { h.f(f_powi(bb(r.f32()))) });
    run!("f_powi5", |r, h| { h.d(f_powi5(bb(r.f64()))) });
    run!("f_sqrt_chk", |r, h| { h.d(f_sqrt_chk(bb(r.f64()))) });
    run!("f_hypot", |r, h| { h.f(f_hypot(bb(r.f32()), bb(r.f32()))) });
    run!("f_copysign", |r, h| { h.f(f_copysign(bb(r.f32()), bb(r.f32()))) });
    run!("f_abs_lt", |r, h| { h.u(f_abs_lt(bb(r.f32())) as u128) });
    run!("f_signum", |r, h| { h.f(f_signum(bb(r.f32()))) });
    run!("f_is_int", |r, h| { h.u(f_is_int(bb(r.f64())) as u128) });
    run!("f_frac", |r, h| { h.d(f_frac(bb(r.f64()))) });
    run!("f_to_bits_sign", |r, h| { h.u(f_to_bits_sign(bb(r.f32())) as u128) });
    run!("f_neg0", |r, h| { h.u(f_neg0(bb(r.f32())) as u128) });
    run!("f_min_max_clamp", |r, h| { h.f(f_min_max_clamp(bb(r.f32()), bb(r.f32()), bb(r.f32()))) });
    run!("f_lerp", |r, h| { h.f(f_lerp(bb(r.f32()), bb(r.f32()), bb(r.f32()))) });
    run!("f_u8_norm", |r, h| { h.f(f_u8_norm(bb(r.u8()))) });
    run!("f_from_u64", |r, h| { h.f(f_from_u64(bb(r.w()))) });
    run!("f_from_u32", |r, h| { h.d(f_from_u32(bb(r.w() as u32))) });
    run!("f_from_u8", |r, h| { h.f(f_from_u8(bb(r.u8()))) });
    run!("f_total_cmp_sort2", |r, h| { let (a, b) = f_total_cmp_sort2(bb(r.f32()), bb(r.f32())); h.f(a); h.f(b) });
    run!("f16_bits_to_f32", |r, h| { h.f(f16_bits_to_f32(bb(r.w() as u16))) });
    run!("color_from_u8", |r, h| { h.u(color_from_u8(bb(r.u8() % 6)).map_or(0, |c| c as u8) as u128) });
    run!("color_to_u8", |r, h| { h.u(color_to_u8(bb(color_from_u8(r.u8() % 6))) as u128) });
    run!("color_next", |r, h| { if let Some(c) = color_from_u8(r.u8() % 6) { h.u(color_next(bb(c)) as u8 as u128) } });
    run!("opt_opt_bool", |r, h| { let x = match r.n() % 4 { 0 => None, 1 => Some(None), 2 => Some(Some(false)), _ => Some(Some(true)) }; h.u(opt_opt_bool(bb(x)) as u128) });
    run!("opt_nz_or", |r, h| { let a = NonZeroU32::new(r.w() as u32 % 3); let b = NonZeroU32::new(r.w() as u32); h.u(opt_nz_or(bb(a), bb(b)).map_or(0, |n| n.get()) as u128) });
    run!("opt_nz_map", |r, h| { let a = NonZeroU32::new(r.w() as u32 % 1000); h.u(opt_nz_map(bb(a)) as u128) });
    run!("opt_ref_is_some", |r, h| { let v = r.u32(); let a = if r.n() % 2 == 0 { None } else { Some(&v) }; h.u(opt_ref_is_some(bb(a)) as u128) });
    run!("opt_ref_unwrap_or", |r, h| { let v = r.u32(); let d = r.u32(); let a = if r.n() % 2 == 0 { None } else { Some(&v) }; h.u(opt_ref_unwrap_or(bb(a), bb(&d)) as u128) });
    run!("res_unit_box", |r, h| { let x: Result<(), Box<u32>> = if r.n() % 2 == 0 { Ok(()) } else { Err(Box::new(r.u32())) }; h.u(res_unit_box(bb(x)) as u128) });
    run!("res_u32_u8", |r, h| { let x: Result<u32, u8> = if r.n() % 2 == 0 { Ok(r.u32()) } else { Err(r.u8()) }; h.u(res_u32_u8(bb(x)) as u128) });
    run!("e3", |r, h| { let v = r.u32(); let e = match r.n() % 3 { 0 => E3::A(v), 1 => E3::B(v), _ => E3::C(v) }; h.u(e3_payload(bb(&e)) as u128); h.u(e3_is_a_or_b(bb(&e)) as u128) });
    run!("e4", |r, h| { let v = r.u32(); let e = match r.n() % 4 { 0 => E4::A, 1 => E4::B(v as u8), 2 => E4::C(v as u16), _ => E4::D(v) }; h.u(e4_size(bb(&e)) as u128); h.u(e4_val(bb(&e)) as u128) });
    run!("ord_opt_max", |r, h| { let a = if r.n() % 3 == 0 { None } else { Some(r.u8()) }; let b = if r.n() % 3 == 0 { None } else { Some(r.u8()) }; h.u(ord_opt_max(bb(a), bb(b)).map_or(999, |x| x as u32) as u128) });
    run!("ret_arr16", |r, h| { let mut a = [0u8; 16]; for x in &mut a { *x = r.u8() } h.b(&ret_arr16(bb(&a))) });
    run!("ret_opt_arr", |r, h| { let a = r.vu8(); let n = r.n() as usize % (a.len() + 4); match ret_opt_arr(bb(&a), bb(n)) { Some(x) => h.b(&x), None => h.u(5) } });
    run!("ret_pair_u8", |r, h| { let (a, b) = ret_pair_u8(bb(r.w() as u16)); h.b(&[a, b]) });
    run!("ret_tuple3", |r, h| { let (a, b, c) = ret_tuple3(bb(r.w() as u32)); h.b(&[a, b, c]) });
    run!("pass_arr4", |r, h| { let a = (r.w() as u32).to_le_bytes(); h.u(pass_arr4(bb(a)) as u128) });
    run!("pass_arr3", |r, h| { let a = (r.w() as u32).to_le_bytes(); h.u(pass_arr3(bb([a[0], a[1], a[2]])) as u128) });
    run!("pass_opt_f32", |r, h| { let a = if r.n() % 3 == 0 { None } else { Some(r.f32()) }; h.f(pass_opt_f32(bb(a))) });
    run!("swap_halves", |r, h| { h.u(swap_halves(bb(r.w())) as u128) });
    run!("parse_u8_dec", |r, h| { let a = r.vu8(); let a = &a[..a.len().min(4)]; h.u(parse_u8_dec(bb(a)).map_or(999, |x| x as u32) as u128) });
    run!("parse_u32_std", |r, h| { let s = r.s(); let s = if r.n() % 2 == 0 { s.chars().filter(|c| c.is_ascii_digit() || *c == '+' || *c == '-').take(12).collect::<String>() } else { s }; h.u(parse_u32_std(bb(&s)).map_or(u64::MAX, |x| x as u64) as u128) });
    run!("starts_with_const", |r, h| { let mut a = r.vu8(); if r.n() % 2 == 0 && a.len() >= 4 { a[..4].copy_from_slice(b"GET ") } h.u(starts_with_const(bb(&a)) as u128) });
    run!("eq_const8", |r, h| { let mut a = r.vu8(); if r.n() % 2 == 0 && a.len() >= 8 { a[..8].copy_from_slice(b"abcdefgh") } h.u(eq_const8(bb(&a)) as u128) });
    run!("eq_ic_slice", |r, h| { let a = r.vu8(); let mut b = a.clone(); for x in &mut b { if x.is_ascii_alphabetic() && r.n() % 2 == 0 { *x ^= 0x20 } } if r.n() % 4 == 0 && !b.is_empty() { let i = r.n() as usize % b.len(); b[i] = r.u8() } if r.n() % 7 == 0 { b.pop(); } h.u(eq_ic_slice(bb(&a), bb(&b)) as u128) });
    run!("count_commas", |r, h| { let a = r.s(); h.u(count_commas(bb(a.as_bytes())) as u128) });
    run!("split_count", |r, h| { let a = r.s(); h.u(split_count(bb(&a)) as u128) });
    run!("trim_start_spaces", |r, h| { let mut a = r.vu8(); let k = r.n() as usize % 5; for x in a.iter_mut().take(k) { *x = b' ' } h.b(trim_start_spaces(bb(&a))) });
    run!("hex_encode", |r, h| { let b = (r.w() as u32).to_le_bytes(); let mut o = [0u8; 8]; hex_encode(bb(&b), bb(&mut o)); h.b(&o) });
    run!("utf8_char_len_first", |r, h| { let a = r.s(); h.u(utf8_char_len_first(bb(&a)) as u128) });
    run!("dyn_known", |r, h| { h.u(dyn_known(bb(r.w() as u32 >> 1)) as u128) });
    run!("dyn_loop", |r, h| { let mut a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 1).collect(); let o: &dyn Op = &Inc; dyn_loop(bb(o), bb(&mut a)); for x in &a { h.u(*x as u128) } });
    run!("closure_apply", |r, h| { let mut a = r.vu32(); let k = r.u32(); closure_apply(bb(&mut a), bb(k)); for x in &a { h.u(*x as u128) } });
    run!("fnptr_call", |r, h| { fn g(x: u32) -> u32 { x.rotate_left(3) ^ 0x55 } h.u(fnptr_call(bb(g), bb(r.u32())) as u128) });
    run!("generic_sum", |r, h| { let a: Vec<u32> = r.vu32().into_iter().map(|x| x >> 12).collect(); h.u(generic_sum(bb(a.iter().copied())) as u128) });
    run!("boxed_slice_sum", |r, h| { let a: Box<[u32]> = r.vu32().into_iter().map(|x| x >> 12).collect(); h.u(boxed_slice_sum(bb(&a)) as u128) });
    for (n, v) in &out { println!("{n:24} {v:016x}"); }
    eprintln!("{} functions, {} iterations each, {}", out.len(), iters, std::env::consts::ARCH);
}
