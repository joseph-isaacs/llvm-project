//! Consolidated reproducers for the codegen findings (no unstable features).
//! Build: rustc -O -C panic=abort --crate-type=lib --emit=asm --edition 2021 -C target-cpu=x86-64-v3 repro.rs
//!        rustc -O -C panic=abort --crate-type=lib --emit=asm --edition 2021 --target aarch64-unknown-linux-gnu repro.rs
//! The portable-simd cases (finding 3) are in repro_simd.rs and need nightly.
use std::cmp::Ordering;

// 1. is_ascii_* select chains (regressed in LLVM 23; compare f1_lib against f1_user)
#[no_mangle] pub fn f1_lib(c: u8) -> bool { c.is_ascii_alphanumeric() }
#[no_mangle] pub fn f1_user(c: u8) -> bool { matches!(c, b'0'..=b'9' | b'A'..=b'Z' | b'a'..=b'z') }
#[no_mangle] pub fn f1_hex(c: u8) -> bool { c.is_ascii_hexdigit() }
#[no_mangle] pub fn f1_punct(c: u8) -> bool { c.is_ascii_punctuation() }
#[no_mangle] pub fn f1_char(c: char) -> bool { c.is_ascii_alphanumeric() }

// 2. SLP over-vectorisation of compare chains on one u64
#[no_mangle] pub fn f2_any_zero(x: u64) -> bool { x.to_ne_bytes().iter().any(|&b| b == 0) }
#[no_mangle] pub fn f2_varint_tail(x: u64) -> u32 { 5 + (x >= 1 << 35) as u32 + (x >= 1 << 42) as u32 + (x >= 1 << 49) as u32 + (x >= 1 << 56) as u32 + (x >= 1 << 63) as u32 }
#[no_mangle] pub fn f2_unpack(f: u8) -> [bool; 8] { std::array::from_fn(|i| f & (1 << i) != 0) }
#[no_mangle] pub fn f2_any_eq(x: u64, n: u8) -> bool { x.to_ne_bytes().iter().any(|&b| b == n) }

// 4. fixed-size byte-array cmp: signum computed twice
#[no_mangle] pub fn f4_lex8(a: &[u8; 8], b: &[u8; 8]) -> Ordering { a.cmp(b) }
#[no_mangle] pub fn f4_lex16(a: &[u8; 16], b: &[u8; 16]) -> Ordering { a.cmp(b) }

// 5. small #[inline] byte classifier never inlined (needs >= 2 callers)
#[derive(Clone, Copy, PartialEq, Eq)] pub enum Tok { Num, Plus, Minus, Star, Slash, LParen, RParen, Ident, Ws, Other }
#[inline] fn classify(c: u8) -> Tok { match c { b'0'..=b'9' => Tok::Num, b'+' => Tok::Plus, b'-' => Tok::Minus, b'*' => Tok::Star, b'/' => Tok::Slash, b'(' => Tok::LParen, b')' => Tok::RParen, b'a'..=b'z' | b'A'..=b'Z' | b'_' => Tok::Ident, b' ' | b'\t' | b'\n' => Tok::Ws, _ => Tok::Other } }
#[no_mangle] pub fn f5_count_nums(s: &[u8]) -> usize { s.iter().filter(|&&c| classify(c) == Tok::Num).count() }
#[no_mangle] pub fn f5_is_ident(c: u8) -> bool { classify(c) == Tok::Ident }
#[no_mangle] pub fn f5_skip_ws(s: &[u8]) -> usize { s.iter().position(|&c| classify(c) != Tok::Ws).unwrap_or(s.len()) }

// 6. derive(PartialEq) on a by-value 4 x u8 struct
#[derive(PartialEq, Clone, Copy)] pub struct P4 { a: u8, b: u8, c: u8, d: u8 }
#[no_mangle] pub fn f6_eq(a: P4, b: P4) -> bool { a == b }

// 7. checked_abs: jo to a block that jumps straight back (x86, regressed)
#[no_mangle] pub fn f7_abs(x: i32) -> Option<i32> { x.checked_abs() }

// 8. character-set matches! spanning > 64 values becomes a jump table on x86
#[no_mangle] pub fn f8_is_op(c: u8) -> bool { matches!(c, b'+' | b'-' | b'*' | b'/' | b'%' | b'<' | b'>' | b'=' | b'!' | b'&' | b'|' | b'^' | b'~') }

// 9. derived Ord compares each field twice on x86
#[derive(PartialEq, Eq, PartialOrd, Ord)] pub struct P3 { a: u32, b: u32, c: u32 }
#[no_mangle] pub fn f9_cmp(a: &P3, b: &P3) -> Ordering { a.cmp(b) }
