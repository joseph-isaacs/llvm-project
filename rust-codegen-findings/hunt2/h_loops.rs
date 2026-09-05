//! Hunt 2, batch A: loop-level passes not exercised by the nine findings.
//! Targets: LoopIdiomRecognize, LoopVectorize (not SLP), IndVarSimplify/LSR, LICM, GVN/DSE, loop unswitch.
//! What to look for is noted per function.

// --- LoopIdiomRecognize: should become memset / memcpy / popcnt / ctlz ---
#[no_mangle] pub fn fill_u8(a: &mut [u8], v: u8) { for x in a { *x = v; } }                         // memset
#[no_mangle] pub fn fill_u32(a: &mut [u32]) { for x in a { *x = 0x01010101; } }                      // memset (byte pattern)
#[no_mangle] pub fn fill_u32_bad(a: &mut [u32]) { for x in a { *x = 0x01020304; } }                  // vector store loop, ok
#[no_mangle] pub fn copy_rev(a: &mut [u32], b: &[u32]) { for i in (0..a.len().min(b.len())).rev() { a[i] = b[i]; } } // memcpy? (reverse loop)
#[no_mangle] pub fn popcnt_loop(mut x: u64) -> u32 { let mut n = 0; while x != 0 { x &= x - 1; n += 1; } n }   // popcnt
#[no_mangle] pub fn popcnt_loop2(x: u64) -> u32 { let mut n = 0; for i in 0..64 { n += ((x >> i) & 1) as u32; } n } // popcnt
#[no_mangle] pub fn clz_loop(x: u32) -> u32 { let mut n = 0; let mut v = x; while v & 0x8000_0000 == 0 && n < 32 { v <<= 1; n += 1; } n } // lzcnt
#[no_mangle] pub fn strlen_like(p: &[u8]) -> usize { let mut i = 0; while i < p.len() && p[i] != 0 { i += 1; } i } // early-exit loop; check vectorisation
#[no_mangle] pub fn find_zero_u32(p: &[u32]) -> Option<usize> { p.iter().position(|&x| x == 0) }

// --- LoopVectorize: reductions and widening ---
#[no_mangle] pub fn sum_u8_as_u64(a: &[u8]) -> u64 { a.iter().map(|&x| x as u64).sum() }              // should use psadbw / uaddlp
#[no_mangle] pub fn sum_u8_as_u32(a: &[u8]) -> u32 { a.iter().map(|&x| x as u32).sum() }
#[no_mangle] pub fn sum_i8_as_i32(a: &[i8]) -> i32 { a.iter().map(|&x| x as i32).sum() }
#[no_mangle] pub fn sat_sum_u8(a: &[u8]) -> u8 { a.iter().fold(0u8, |s, &x| s.saturating_add(x)) }   // sequential dep, expect scalar
#[no_mangle] pub fn sat_add_slices(a: &mut [u8], b: &[u8]) { for (x, y) in a.iter_mut().zip(b) { *x = x.saturating_add(*y); } } // vpaddusb
#[no_mangle] pub fn sat_sub_slices(a: &mut [u8], b: &[u8]) { for (x, y) in a.iter_mut().zip(b) { *x = x.saturating_sub(*y); } }
#[no_mangle] pub fn wrapping_add_slices(a: &mut [u8], b: &[u8]) { for (x, y) in a.iter_mut().zip(b) { *x = x.wrapping_add(*y); } }
#[no_mangle] pub fn abs_diff_sum(a: &[u8], b: &[u8]) -> u32 { a.iter().zip(b).map(|(&x, &y)| x.abs_diff(y) as u32).sum() } // psadbw
#[no_mangle] pub fn min_by_key_idx(a: &[u32]) -> Option<usize> { a.iter().enumerate().min_by_key(|&(_, &v)| v).map(|(i, _)| i) }
#[no_mangle] pub fn any_gt(a: &[i32], t: i32) -> bool { a.iter().any(|&x| x > t) }                    // early exit
#[no_mangle] pub fn all_in_range(a: &[u8]) -> bool { a.iter().all(|&x| (b'a'..=b'z').contains(&x)) }
#[no_mangle] pub fn count_set_bits(a: &[u64]) -> u32 { a.iter().map(|x| x.count_ones()).sum() }      // popcnt loop / vpshufb
#[no_mangle] pub fn xor_fold_u8(a: &[u8]) -> u8 { a.iter().fold(0, |s, &x| s ^ x) }
#[no_mangle] pub fn max_f32(a: &[f32]) -> f32 { a.iter().copied().fold(f32::MIN, f32::max) }         // maxps? (NaN semantics)
#[no_mangle] pub fn max_f32_nan(a: &[f32]) -> f32 { a.iter().copied().fold(f32::NAN, |m, x| if x > m || m.is_nan() { x } else { m }) }
#[no_mangle] pub fn dot_f32(a: &[f32], b: &[f32]) -> f32 { a.iter().zip(b).map(|(x, y)| x * y).sum() } // no fast-math: scalar expected
#[no_mangle] pub fn scale_i16(a: &mut [i16], k: i16) { for x in a { *x = ((*x as i32 * k as i32) >> 8) as i16; } } // pmulhw-ish
#[no_mangle] pub fn clamp_u8(a: &mut [i32], out: &mut [u8]) { for (o, &x) in out.iter_mut().zip(a.iter()) { *o = x.clamp(0, 255) as u8; } } // packusdw
#[no_mangle] pub fn bytes_to_u16(a: &[u8], out: &mut [u16]) { for (o, &x) in out.iter_mut().zip(a) { *o = x as u16; } } // pmovzxbw
#[no_mangle] pub fn u16_to_bytes(a: &[u16], out: &mut [u8]) { for (o, &x) in out.iter_mut().zip(a) { *o = x as u8; } } // pack
#[no_mangle] pub fn bool_count(a: &[bool]) -> usize { a.iter().filter(|&&b| b).count() }
#[no_mangle] pub fn prefix_sum(a: &mut [u32]) { for i in 1..a.len() { a[i] += a[i - 1]; } }             // expect scalar; check bounds checks
#[no_mangle] pub fn stride2_sum(a: &[u32]) -> u32 { a.iter().step_by(2).sum() }                        // IndVar: step_by lowering
#[no_mangle] pub fn rev_sum(a: &[u32]) -> u32 { a.iter().rev().sum() }
#[no_mangle] pub fn chunks4_sum(a: &[u32]) -> u32 { a.chunks_exact(4).map(|c| c[0] + c[1] + c[2] + c[3]).sum() }
#[no_mangle] pub fn windows2_cmp(a: &[u32]) -> bool { a.windows(2).all(|w| w[0] <= w[1]) }             // is_sorted
#[no_mangle] pub fn is_sorted_std(a: &[u32]) -> bool { a.is_sorted() }
#[no_mangle] pub fn enumerate_bounds(a: &[u32], b: &mut [u32]) { for (i, &x) in a.iter().enumerate() { if i < b.len() { b[i] = x; } } } // bounds check inside loop
#[no_mangle] pub fn zip3(a: &[u32], b: &[u32], c: &mut [u32]) { for i in 0..c.len() { c[i] = a[i] + b[i]; } } // 2 bounds checks per iter, vectorised?
#[no_mangle] pub fn zip3_iter(a: &[u32], b: &[u32], c: &mut [u32]) { for ((c, a), b) in c.iter_mut().zip(a).zip(b) { *c = a + b; } }
#[no_mangle] pub fn transpose4(m: &mut [[u32; 4]; 4]) { for i in 0..4 { for j in i + 1..4 { let t = m[i][j]; m[i][j] = m[j][i]; m[j][i] = t; } } }
#[no_mangle] pub fn hist16(a: &[u8], h: &mut [u32; 16]) { for &b in a { h[(b & 15) as usize] += 1; } }
#[no_mangle] pub fn nested_const(a: &mut [u8; 64]) { for i in 0..8 { for j in 0..8 { a[i * 8 + j] = (i ^ j) as u8; } } } // full unroll + store merge

// --- LICM / GVN / DSE ---
pub struct Acc { pub sum: u64, pub count: u32, pub max: u32 }
#[no_mangle] pub fn acc_loop(acc: &mut Acc, a: &[u32]) { for &x in a { acc.sum += x as u64; acc.count += 1; acc.max = acc.max.max(x); } } // fields should stay in registers
#[no_mangle] pub fn acc_loop_opt(acc: &mut Option<Acc>, a: &[u32]) { for &x in a { if let Some(acc) = acc { acc.sum += x as u64; } } } // hoist the discriminant test
#[no_mangle] pub fn vec_push_loop(v: &mut Vec<u8>, n: usize) { for i in 0..n { v.push(i as u8); } }   // grow check per iteration (known?)
#[no_mangle] pub fn vec_extend(v: &mut Vec<u8>, n: usize) { v.extend((0..n).map(|i| i as u8)); }
#[no_mangle] pub fn opt_take_loop(a: &mut [Option<u32>]) -> u32 { a.iter_mut().filter_map(|x| x.take()).sum() }
#[no_mangle] pub fn swap_pairs(a: &mut [u32]) { for c in a.chunks_exact_mut(2) { c.swap(0, 1); } }   // pshufd / rev64
#[no_mangle] pub fn bswap_all(a: &mut [u32]) { for x in a { *x = x.swap_bytes(); } }                 // pshufb
#[no_mangle] pub fn shift_all(a: &mut [u32], s: u32) { for x in a { *x >>= s; } }                    // s masked once
#[no_mangle] pub fn div_all(a: &mut [u32], d: u32) { for x in a { *x /= d; } }                       // div-by-zero check hoisted? div per element
#[no_mangle] pub fn mod10_all(a: &mut [u32]) { for x in a { *x %= 10; } }                            // mul-shift, vectorised
#[no_mangle] pub fn unswitch(a: &mut [u32], neg: bool) { for x in a { if neg { *x = x.wrapping_neg(); } else { *x += 1; } } } // loop unswitch
