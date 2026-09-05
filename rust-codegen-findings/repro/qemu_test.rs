//! Correctness harness for the nine reproducers: compares each optimised function against a
//! straightforward reference over exhaustive (u8/u16) or pseudo-random (u32/u64) inputs.
//! Build natively and for aarch64, run the latter under qemu-user:
//!   rustc +nightly -O -C panic=abort --edition 2021 qemu_test.rs -o t_x86 && ./t_x86
//!   rustc +nightly -O -C panic=abort --edition 2021 --target aarch64-unknown-linux-gnu \
//!       -C linker=aarch64-linux-gnu-gcc qemu_test.rs -o t_arm && qemu-aarch64 -L /usr/aarch64-linux-gnu ./t_arm
//! (see qemu.sh for a static-link variant that needs no cross sysroot)
use std::cmp::Ordering;
use std::hint::black_box as bb;

#[inline(never)] fn f1(c: u8) -> bool { c.is_ascii_alphanumeric() }
#[inline(never)] fn f2a(x: u64) -> bool { x.to_ne_bytes().iter().any(|&b| b == 0) }
#[inline(never)] fn f2b(x: u64) -> u32 { (x >= 1 << 35) as u32 + (x >= 1 << 42) as u32 + (x >= 1 << 49) as u32 + (x >= 1 << 56) as u32 }
#[inline(never)] fn f2c(f: u8) -> [bool; 8] { std::array::from_fn(|i| f & (1 << i) != 0) }
#[inline(never)] fn f4(a: &[u8; 8], b: &[u8; 8]) -> Ordering { a.cmp(b) }
#[derive(Clone, Copy, PartialEq, Eq, Debug)] enum Tok { Num, Plus, Minus, Star, Slash, LParen, RParen, Ident, Ws, Other }
#[inline] fn classify(c: u8) -> Tok { match c { b'0'..=b'9' => Tok::Num, b'+' => Tok::Plus, b'-' => Tok::Minus, b'*' => Tok::Star, b'/' => Tok::Slash, b'(' => Tok::LParen, b')' => Tok::RParen, b'a'..=b'z' | b'A'..=b'Z' | b'_' => Tok::Ident, b' ' | b'\t' | b'\n' => Tok::Ws, _ => Tok::Other } }
#[inline(never)] fn f5a(c: u8) -> bool { classify(c) == Tok::Ident }
#[inline(never)] fn f5b(s: &[u8]) -> usize { s.iter().filter(|&&c| classify(c) == Tok::Num).count() }
#[derive(PartialEq, Clone, Copy)] struct P4(u8, u8, u8, u8);
#[inline(never)] fn f6(a: P4, b: P4) -> bool { a == b }
#[inline(never)] fn f7(x: i32) -> Option<i32> { x.checked_abs() }
#[inline(never)] fn f8(c: u8) -> bool { matches!(c, b'+' | b'-' | b'*' | b'/' | b'%' | b'<' | b'>' | b'=' | b'!' | b'&' | b'|' | b'^' | b'~') }
#[derive(PartialEq, Eq, PartialOrd, Ord, Clone, Copy)] struct P3(u32, u32, u32);
#[inline(never)] fn f9(a: &P3, b: &P3) -> Ordering { a.cmp(b) }

fn rng(s: &mut u64) -> u64 { *s ^= *s << 13; *s ^= *s >> 7; *s ^= *s << 17; *s }

fn main() {
    let mut fails = 0u32;
    macro_rules! check { ($name:expr, $cond:expr) => { if !$cond { fails += 1; if fails < 20 { eprintln!("FAIL {}", $name); } } } }
    // exhaustive over u8
    for c in 0u8..=255 {
        let alnum = (b'0'..=b'9').contains(&c) || (b'A'..=b'Z').contains(&c) || (b'a'..=b'z').contains(&c);
        check!(format!("f1({c})"), f1(bb(c)) == alnum);
        let ident = alnum && !(b'0'..=b'9').contains(&c) || c == b'_';
        check!(format!("f5a({c})"), f5a(bb(c)) == ident);
        check!(format!("f8({c})"), f8(bb(c)) == b"+-*/%<>=!&|^~".contains(&c));
        let bits = f2c(bb(c)); for i in 0..8 { check!(format!("f2c({c})[{i}]"), bits[i] == ((c >> i) & 1 == 1)); }
    }
    // random u64 / u32 / structs
    let mut s = 0x9E3779B97F4A7C15u64;
    for _ in 0..2_000_000 {
        let x = rng(&mut s);
        let x = match x & 3 { 0 => x & 0x00ff_ff00_ff00_ffff, 1 => x >> (x % 64), _ => x }; // bias toward zero bytes / small values
        check!(format!("f2a({x:#x})"), f2a(bb(x)) == x.to_le_bytes().contains(&0));
        let r = [35u32, 42, 49, 56].iter().filter(|&&k| x >= 1u64 << k).count() as u32;
        check!(format!("f2b({x:#x})"), f2b(bb(x)) == r);
        let a = x.to_le_bytes(); let mut b = rng(&mut s).to_le_bytes(); if x & 8 == 0 { b = a; } if x & 16 == 0 { b[(x as usize >> 5) & 7] ^= 1; }
        let refcmp = a.iter().cmp(b.iter());
        check!(format!("f4({a:?},{b:?})"), f4(bb(&a), bb(&b)) == refcmp);
        let pa = P4(a[0], a[1], a[2], a[3]); let pb = P4(b[0], b[1], b[2], b[3]);
        check!(format!("f6"), f6(bb(pa), bb(pb)) == (a[..4] == b[..4]));
        let i = x as i32; let refabs = if i == i32::MIN { None } else { Some(i.abs()) };
        check!(format!("f7({i})"), f7(bb(i)) == refabs);
        let ta = P3(x as u32, (x >> 32) as u32, a[0] as u32); let tb = P3(if x & 32 == 0 { ta.0 } else { b[0] as u32 }, if x & 64 == 0 { ta.1 } else { b[1] as u32 }, b[2] as u32);
        let r9 = ta.0.cmp(&tb.0).then(ta.1.cmp(&tb.1)).then(ta.2.cmp(&tb.2));
        check!(format!("f9"), f9(bb(&ta), bb(&tb)) == r9);
    }
    for i in i32::MIN..=i32::MIN + 3 { check!(format!("f7 edge {i}"), f7(bb(i)) == if i == i32::MIN { None } else { Some(-i) }); }
    let text = b"let x1 = (a2 + 30) * b_4 / 7;\n";
    check!("f5b", f5b(bb(text)) == text.iter().filter(|c| c.is_ascii_digit()).count());
    if fails == 0 { println!("all reproducers compute correct results on {}", std::env::consts::ARCH); }
    else { println!("{fails} FAILURES on {}", std::env::consts::ARCH); std::process::exit(1); }
}
