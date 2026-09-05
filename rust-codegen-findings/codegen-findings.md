# Rust codegen findings, x86-64 and AArch64

Method: ~350 small functions across numeric branching, byte/bit tricks, portable-simd bit ops, `Option`/`Result`/enum dispatch and byte classifiers were compiled with
`rustc 1.100.0-nightly (0ed41eb41 2026-09-04)` (LLVM 23.1.1) at `-C opt-level=3 -C panic=abort` for
`x86_64-unknown-linux-gnu -C target-cpu=x86-64-v3` and `aarch64-unknown-linux-gnu`, and compared against
stable 1.94.1 (LLVM 21.1.8), clang trunk / opt trunk / llc trunk and opt 21.1/22.1 (via Compiler Explorer), and clang 18.
Every finding below was checked against existing rust-lang/rust, rust-lang/portable-simd and llvm/llvm-project issues by title search; none appears to be filed in this form.

Regression status is against stable 1.94.1 (LLVM 21).

| # | Finding | Targets | Layer | Regression? |
|---|---------|---------|-------|-------------|
| 1 | `is_ascii_alphanumeric` / `is_ascii_hexdigit` / `is_ascii_punctuation` now compile to select/cmov chains | x86, aarch64 | LLVM 23 (rustc IR shape) | **yes** (LLVM 22.1 ok, 23 bad) |
| 2 | SLP vectorizer turns a few scalar compares on one `u64` into wide vector code (`to_ne_bytes().iter().any`, varint length, `[bool; 8]` unpack) | x86, aarch64 | LLVM 23 | **partly** (varint case new in 23) |
| 3 | `Mask::to_bitmask()` for 2- and 4-lane masks: `vpcmpgtq/vpackssdw/vpermq/vmovmskps` instead of one `vmovmskpd` | x86 (aarch64 minor) | portable-simd | no (long-standing) |
| 4 | `[u8; N]::cmp` / tuple `Ord` with byte arrays: redundant second sign-normalisation after memcmp expansion | x86, aarch64 | LLVM pipeline order | no |
| 5 | `#[inline]` byte classifier `match` is never inlined (7 callers) because a 10-case switch is charged as an 87-entry jump table | x86, aarch64 | LLVM inline cost | no |
| 6 | `#[derive(PartialEq)]` on a by-value `{u8,u8,u8,u8}` struct: three compares and branches instead of one 32-bit compare | x86, aarch64 | rustc IR shape / LLVM | no |
| 7 | `i32::checked_abs()`: `jo L1; L2: ... ; L1: jmp L2` (branch to fallthrough) | x86 | LLVM SelectOptimize | **yes** |
| 8 | `matches!(c, b'+' \| b'-' \| ... 13 chars)` becomes a 94-entry jump table on x86 | x86 | LLVM switch lowering | no |
| 9 | derived `Ord::cmp` on multi-field structs compares each field twice | x86 | LLVM | no |

Reproducer sources are in `repro/`; the second hunt is in `hunt2/`.

---

## 1. `u8::is_ascii_alphanumeric()` and friends regressed to select chains (LLVM 23)

```rust
#[unsafe(no_mangle)] pub fn lib(c: u8) -> bool { c.is_ascii_alphanumeric() }
#[unsafe(no_mangle)] pub fn user(c: u8) -> bool { matches!(c, b'0'..=b'9' | b'A'..=b'Z' | b'a'..=b'z') }
```

nightly, x86-64-v3:

```asm
lib:                                  user:
    leal    -48(%rdi), %eax               leal    -48(%rdi), %eax
    xorl    %ecx, %ecx                    cmpb    $10, %al
    cmpb    $10, %al                      setb    %cl
    setb    %cl                           andb    $-33, %dil
    xorl    %eax, %eax                    addb    $-65, %dil
    cmpb    $91, %dil                     cmpb    $26, %dil
    setb    %al                           setb    %al
    cmpb    $65, %dil                     orb     %cl, %al
    cmovael %eax, %ecx                    retq
    xorl    %eax, %eax
    cmpb    $123, %dil
    setb    %al
    cmpb    $97, %dil
    cmovbl  %ecx, %eax
    retq
```

nightly, aarch64: `lib` is 12 instructions of `cmp`/`cset`/`csel`; `user` is 8 (`cmp`+`ccmp`+`cset`).
Stable 1.94.1 produces the `user` form for both. `char::is_ascii_alphanumeric`, `u8::is_ascii_hexdigit` (14 instr) and `u8::is_ascii_punctuation` (18 instr) are affected the same way; `is_ascii_alphabetic` is not.

Cause. The library writes these as `matches!(*self, b'0'..=b'9') | matches!(*self, b'A'..=b'Z') | matches!(*self, b'a'..=b'z')` (`library/core/src/num/mod.rs:931`). rustc lowers each `matches!(x, lo..=hi)` as a two-way branch that stores `x <= hi` or `false` into an alloca; the `|` is an `or i1` on the loaded values. Running that pre-optimisation IR through `opt -O3`:

* opt 21.1 and 22.1: `or (icmp ult (add c,-48), 10), (icmp ult (add (and c,-33),-65), 26)` (good)
* opt trunk: SimplifyCFG speculates the second range check into `select (c >u 64), (or %prev, c <u 91), %prev`; InstCombine then simplifies that to `select (c >u 64), (c <u 91), %prev`, which is neither a logical and nor a logical or, so the "or of two range checks that differ in one bit" fold never fires (`-print-changed` shows the select appearing after SimplifyCFG and surviving every later InstCombine).

`tests/codegen-llvm/char-ascii-branchless.rs` only asserts `CHECK-NOT: br`, so it still passes (see rust-lang/rust#153504 for the earlier LLVM 23 breakage of that test).

Two independent fixes: in the library, write these as one `matches!` with an or-pattern (the `user` form above, which produces the fused range check on both LLVM versions); in LLVM, teach InstCombine to turn `select(A, B, X)` back into `or(and(A,B), X)` when `X` is known false under `A`, or stop SimplifyCFG from sinking the `or` into the select.

## 2. SLP vectoriser over-vectorises scalar compare chains on a single `u64`

```rust
#[unsafe(no_mangle)] pub fn any_zero_byte(x: u64) -> bool { x.to_ne_bytes().iter().any(|&b| b == 0) }
#[unsafe(no_mangle)] pub fn varint_tail(x: u64) -> u32 {
    5 + (x >= 1 << 35) as u32 + (x >= 1 << 42) as u32 + (x >= 1 << 49) as u32 + (x >= 1 << 56) as u32 + (x >= 1 << 63) as u32 }
#[unsafe(no_mangle)] pub fn unpack(f: u8) -> [bool; 8] { std::array::from_fn(|i| f & (1 << i) != 0) }
#[unsafe(no_mangle)] pub fn max_byte(x: u64) -> u8 { x.to_ne_bytes().iter().copied().max().unwrap() }
```

`any_zero_byte`, nightly x86-64-v3 (28 instructions; `u32` version is scalar):

```asm
    vpbroadcastd  .LCPI_4(%rip), %xmm0
    vpinsrq       $0, %rdi, %xmm0, %xmm0
    vmovq         %rdi, %xmm1
    vpbroadcastq  %xmm1, %ymm1
    vinserti128   $1, %xmm0, %ymm1, %ymm0
    vpand ... vpand ... vpslldq ... vpxor ... vinserti128 ... vpcmpeqq ... vpcmpeqq ... vpackssdw
    vextracti128 ... vpackssdw ... vpbroadcastq ... vpor ... vpxor ... vpcmpgtq ... vpackssdw
    vextracti128 ... vpackssdw ... vpshufd ... vpblendw ... vpsllw $15 ... vpmovmskb
    testl   $43690, %eax
    setne   %al
    vzeroupper
    retq
```

The IR is `<8 x i64>` `and` with per-lane byte masks followed by `icmp eq`/`icmp ult <8 x i64>` and a `bitcast <8 x i1> to i8`. AArch64 gets 35 NEON instructions. Scalar is ~11 instructions, and the classic `(x - 0x0101..) & !x & 0x8080..` is 5. Stable 1.94 already vectorised half of it (26 instr), clang trunk gives 14, so the cost model has been wrong for a while and got worse.

`varint_tail` is a clean regression: stable 1.94 emits 17 scalar instructions; nightly emits `vpbroadcastq / vpxor / vpcmpgtq / vextracti128 / vpackssdw / vpsubd / 2x vpshufd+vpaddd / vmovd / vzeroupper` (x86) and `dup/cmhi/cmhi/uzp1/bsl/addv` with four constant-pool loads (aarch64). Running the pre-opt IR through opt 22.1 keeps it scalar; opt trunk vectorises it. clang trunk reproduces with the C equivalent.

`unpack` ([bool; 8] from a byte) is 20 AVX2 instructions (`vpmullw`, two `vpsllvq`, ...) on x86 and 30 NEON instructions on aarch64; `pdep` (BMI2 is in x86-64-v3) or eight scalar shifts would do. `flags_cnt8` (`(f&1!=0) as u32 + ... + (f&128!=0) as u32`) is another instance (should be `popcnt`).

AArch64-specific extra: when the bytes are compared against a variable (`any(|&b| b == n)`) or reduced with `max`, AArch64 builds the `<8 x i8>` from `x` with four `ushl v.2d` and three `uzp1`/`xtn` (10 vector ops) instead of `fmov d0, x0`; x86 does the right thing (`vmovq; vpbroadcastb; vpcmpeqb; vpmovmskb`). clang trunk on armv8 reproduces.

## 3. `Mask::to_bitmask()` on 2- and 4-lane masks (portable-simd)

```rust
#![feature(portable_simd, core_intrinsics)]
use std::simd::prelude::*; use std::intrinsics::simd::simd_bitmask;
#[unsafe(no_mangle)] pub fn lib(v: mask64x2) -> u64 { v.to_bitmask() }
#[unsafe(no_mangle)] pub fn direct(v: mask64x2) -> u64 { unsafe { simd_bitmask::<_, u8>(v.to_simd()) as u64 } }
#[unsafe(no_mangle)] pub fn lib4(a: f64x4, b: f64x4) -> u64 { a.simd_lt(b).to_bitmask() }
#[unsafe(no_mangle)] pub fn direct4(a: f64x4, b: f64x4) -> u64 { unsafe { simd_bitmask::<_, u8>(a.simd_lt(b).to_simd()) as u64 } }
```

nightly x86-64-v3:

```asm
lib:                                       direct:
    vmovdqa  (%rdi), %xmm0                     vmovapd   (%rdi), %xmm0
    vpxor    %xmm1, %xmm1, %xmm1               vmovmskpd %xmm0, %eax
    vpcmpgtq %ymm0, %ymm1, %ymm0               retq
    vpackssdw %ymm1, %ymm0, %ymm0
    vpermq   $216, %ymm0, %ymm0
    vmovmskps %ymm0, %eax
    vzeroupper
    retq
lib4:                                      direct4:
    vmovapd  (%rdi), %ymm0                     vmovapd   (%rdi), %ymm0
    vcmpltpd (%rsi), %ymm0, %ymm0              vcmpltpd  (%rsi), %ymm0, %ymm0
    vpxor    %xmm1, %xmm1, %xmm1               vmovmskpd %ymm0, %eax
    vpackssdw %ymm1, %ymm0, %ymm0              vzeroupper
    vpermq   $216, %ymm0, %ymm0                retq
    vmovmskps %ymm0, %eax
    vzeroupper
    retq
```

`mask32x4::to_bitmask()` / `f32x4::simd_lt().to_bitmask()` read `vmovmskps %ymm0` plus `vzeroupper` instead of `vmovmskps %xmm0`; on baseline x86-64 (SSE2) `mask32x4` is `pxor/packssdw/packsswb/pmovmskb/movzbl` (6) vs `movmskps` (1), and `mask64x2` is 8 vs 1. `mask16x4`/`mask8x4` are similar. On aarch64 the library form adds `xtn`+`uzp1` and, with LLVM 23, a stack round trip (`str b0, [sp,#12]; ldrb w0, [sp,#12]`) that llc trunk no longer emits.

Cause. `Mask::to_bitmask` (`crates/core_simd/src/masks.rs:302`) does `mask.resize::<M>(false)` to 8/16/32/64 lanes before calling `simd_bitmask`, with the comment "TODO modify simd_bitmask to zero-extend output, making this unnecessary". `rustc_codegen_llvm` (`intrinsic.rs`, `simd_bitmask`) already accepts a return type of `in_len.max(8).next_power_of_two()` bits and emits `bitcast <N x i1> to iN; zext`, so the resize is redundant. The widened `<8 x i64>` compare is what breaks the `movmsk` pattern match (llc trunk: `bitcast <2 x i1>` -> `vmovmskpd`, the resized `<8 x i64>` form -> the 6-instruction sequence). `first_set`, `any` after `to_bitmask` etc. inherit it. Fix: call `simd_bitmask` directly for `N < M`. Checked portable-simd issues for `to_bitmask` (#375, #377, #423, #312): none cover this.

## 4. Fixed-size byte-array `cmp`: sign-normalisation done twice

```rust
#[unsafe(no_mangle)] pub fn lex8(a: &[u8; 8], b: &[u8; 8]) -> Ordering { a.cmp(b) }
```

nightly x86-64-v3 (identical on stable; also `[u8;4]`, `[u8;16]`, `([u8;8], u32)`, `str`/`&[u8]` when the length is known):

```asm
lex8:
    movbeq  (%rdi), %rax
    movbeq  (%rsi), %rcx
    cmpq    %rcx, %rax
    seta    %al
    sbbb    $0, %al          ; already -1/0/1
    movsbq  %al, %rax
    testq   %rax, %rax
    sets    %cl
    setg    %al
    subb    %cl, %al         ; signum of a signum
    retq
```

aarch64 has the same `cset hi; csinv hs; sxtw; cmp #0; cset gt; csinv pl`, and for `[u8; 16]` the equal path is `mov w8, wzr; sxtw x8, w8; cmp x8, #0; cset; csinv` (signum of a literal zero).

Final IR: `%4 = ucmp.i32.i64(bswap a, bswap b); %5 = sext %4; scmp.i8.i64(%5, 0)`. `opt -O3` trunk folds exactly this input to a single `ucmp.i8.i64` (LLVM #202467 / PR #218871 added the `scmp(sext x, 0)` fold), but in the real pipeline the `ucmp` is created by `ExpandMemCmpPass`, which now sits in the late `OptimizePM` (`llvm/lib/Passes/PassBuilderPipelines.cpp` ~line 1661) after the last InstCombine, so nothing ever sees it. clang trunk (C `memcmp(a,b,8)` + signum) emits the same code on both targets. Fix options: an InstCombine/InstSimplify run (or a targeted fold) after ExpandMemCmp, or a DAG combine `scmp(x, 0) -> x` when `x` is known to be in `[-1, 1]`.

## 5. Small `match`-based byte classifier is never inlined

```rust
#[derive(Clone, Copy, PartialEq, Eq)] pub enum Tok { Num, Plus, Minus, Star, Slash, LParen, RParen, Ident, Ws, Other }
#[inline] fn classify(c: u8) -> Tok { match c {
    b'0'..=b'9' => Tok::Num, b'+' => Tok::Plus, b'-' => Tok::Minus, b'*' => Tok::Star, b'/' => Tok::Slash,
    b'(' => Tok::LParen, b')' => Tok::RParen, b'a'..=b'z' | b'A'..=b'Z' | b'_' => Tok::Ident,
    b' ' | b'\t' | b'\n' => Tok::Ws, _ => Tok::Other } }
#[unsafe(no_mangle)] pub fn count_nums(s: &[u8]) -> usize { s.iter().filter(|&&c| classify(c) == Tok::Num).count() }
#[unsafe(no_mangle)] pub fn is_ident_tok(c: u8) -> bool { classify(c) == Tok::Ident }
// ... 5 more small callers (skip_ws, count_ops, count_toks, ...)
```

With two or more callers `classify` is not inlined anywhere, on either target, on stable or nightly:

```asm
is_ident_tok:                       count_nums:  .LBB14_3:
    pushq   %rax                        movzbl  (%r15,%r12), %edi
    callq   classify                    callq   classify
    cmpb    $7, %al                     cmpb    $1, %al
    sete    %al                         adcq    $0, %rbx
    popq    %rcx                        incq    %r12
    retq                                cmpq    %r12, %r14
                                        jne     .LBB14_3
```

The optimised callee is 13 instructions: one range check, a 10-case `switch` (cases 9..=95), one more range check, a phi. LLVM's `InlineCostCallAnalyzer::onFinalizeSwitch` charges a switch that would become a jump table `JumpTableSize * InstrCost + 2 * InstrCost` = 87*5 + 10 ~= 445, above the `inlinehint` threshold of 325 (the `print<inline-cost>` pass confirms threshold 325 at every call site). `-C llvm-args=-inline-threshold=500` or `#[inline(always)]` inlines it; `-Zinline-mir-threshold` up to 400 does not help (the MIR inliner declines too). This pattern (a `match` on byte literals shared by several lexer helpers) is extremely common in Rust and never gets the loop-level optimisation it looks like it should.

Second-order: once inlined, `classify(c) == Tok::Ident` becomes an 87-entry jump table (`is_ident_tok` with `inline(always)`), because the switch cases for `+ - * / ( ) space tab nl` all jump to `false` while the default block does the alphabetic range check, and nothing proves those case values would fail the range check anyway.

## 6. `#[derive(PartialEq)]` on a by-value 4 x u8 struct

```rust
#[derive(PartialEq, Clone, Copy)] pub struct P4 { a: u8, b: u8, c: u8, d: u8 }
#[unsafe(no_mangle)] pub fn eq(a: P4, b: P4) -> bool { a == b }
```

```asm
; x86-64 nightly (same on stable)         ; aarch64 nightly
eq:                                        eq:
    cmpb    %sil, %dil                         ubfx    w8, w0, #8, #16
    jne     .LBB6_4                            lsr     w9, w1, #8
    movl    %edi, %eax                         eor     w10, w1, w0
    shrl    $8, %eax                           cmp     wzr, w10, lsr #24
    movl    %esi, %ecx                         and     w10, w0, #0xff
    shrl    $8, %ecx                           cset    w11, eq
    cmpw    %cx, %ax                           cmp     w8, w9, uxth
    jne     .LBB6_4                            csel    w8, wzr, w11, ne
    xorl    %edi, %esi                         cmp     w10, w1, uxtb
    cmpl    $16777216, %esi                    csel    w0, wzr, w8, ne
    setb    %al                                ret
    retq
.LBB6_4:
    xorl    %eax, %eax
    retq
```

clang trunk for the C struct compiles to `cmpl %esi, %edi; sete %al` / `eor; cmp; cset`. The struct arrives in one 32-bit register; rustc stores it to an alloca, memcpys to an align-1 copy and loads `i8` fields, and the derived `&&` chain stays as three branches. After SROA the middle compare needs `lshr`+`trunc` on each side, which exceeds SimplifyCFG's one-bonus-instruction budget in `FoldBranchToCommonDest`, so the chain is never flattened into `and`s where InstCombine could merge the masked compares; MergeICmps only handles loads. Related but different shape: rust-lang/rust#140167 (2 x u16 by reference). The by-reference `{u32,u32,u32}` version is merged fine.

## 7. `i32::checked_abs()` emits a conditional jump to the next instruction (x86, regression)

```rust
#[unsafe(no_mangle)] pub fn abs_chk(x: i32) -> Option<i32> { x.checked_abs() }
```

```asm
; nightly                              ; stable 1.94.1
abs_chk:                               abs_chk:
    movl    %edi, %edx                     xorl    %eax, %eax
    negl    %edx                           movl    %edi, %edx
    jo      .LBB0_1                        negl    %edx
.LBB0_2:                                   setno   %al
    xorl    %eax, %eax                     testl   %edi, %edi
    movl    %edi, %ecx                     cmovnsl %edi, %edx
    negl    %ecx                           retq
    setno   %al
    testl   %edi, %edi
    cmovnsl %edi, %edx
    retq
.LBB0_1:
    jmp     .LBB0_2
```

Final IR contains `select i1 %ne_min, i32 %neg, i32 undef, !prof !{"branch_weights", !"expected", i32 2000, i32 1}` (the `undef` is the `None` payload, the profile comes from `unlikely!` in `overflowing_neg`). `opt -O3` trunk does not fold the select-with-undef, and x86 `SelectOptimize` then converts the profiled select into a branch whose "else" block is empty: `llc trunk` on that IR gives `jno .LBB0_2; .LBB0_2:`. Without the `!prof` the select lowers to the stable code. AArch64 is unaffected (7 instructions, no branch).

## 8. `matches!` over a set of characters spanning > 64 values becomes a jump table on x86

```rust
#[unsafe(no_mangle)] pub fn is_op(c: u8) -> bool {
    matches!(c, b'+' | b'-' | b'*' | b'/' | b'%' | b'<' | b'>' | b'=' | b'!' | b'&' | b'|' | b'^' | b'~') }
```

x86-64: `addl $-33; cmpl $93; ja; leaq .LJTI(%rip); movslq; addq; jmpq *%rcx` plus a 94-entry table (376 bytes) to produce one bit. AArch64 splits it into a 62-wide bit test (`lsr x9, x10, x9; tbz`) plus two compares. Sets that fit in 64 values (`is_vowel_ic2`, `is_brace`) get the bit-test on both. clang trunk does the same with a C `switch`, so this is x86 switch lowering / `SwitchToLookupTable` declining a >64-entry `i1` table.

## 9. Derived `Ord` on multi-field structs compares each field twice (x86, minor)

```rust
#[derive(PartialEq, Eq, PartialOrd, Ord)] pub struct P3 { a: u32, b: u32, c: u32 }
#[unsafe(no_mangle)] pub fn cmp(a: &P3, b: &P3) -> Ordering { a.cmp(b) }
```

```asm
cmp:
    movl    (%rdi), %ecx
    movl    (%rsi), %edx
    cmpl    %edx, %ecx
    seta    %al
    sbbb    $0, %al
    cmpl    %edx, %ecx      ; second compare of the same operands
    jne     .LBB81_3
    ...
```

`a.cmp(&b).then(c.cmp(&d))` gets the ideal `cmpl; jne; cmpl; seta; sbbb`. Same for `(u32,u32,u32)`, `(u64,u8)` and the derived 4 x u8 struct (which additionally does not collapse to a `bswap` compare the way `[u8;4]` does).

---

## Checked and not reported (already known or by design)

* Separate bounds checks for `a[i] + a[i+1] + a[i+2]` and `if i + 2 < a.len()` (wrapping `i+2`), `windows(3)` - known.
* `f32::min` = three `fminnm` on aarch64 (sNaN quieting) - known.
* `u8x16::load_or_default` scalarised into 16 branches (masked byte loads) - LLVM limitation, both targets.
* `<[u8]>::iter().all(|b| b < 128)` not vectorised (early exit) - known; `is_ascii()` is fine.
* `u32::isqrt` and `u64::isqrt` size - rust-lang/rust#150653.
* `x.clamp(lo, hi)` carrying the `min > max` panic path - by design.
* `Option<u32> == Option<u32>` branches, `#[derive(PartialEq)]` by reference on 2 x u16 - rust-lang/rust#140167.
* `select`-based `to_upper3` (`m.select(v & !0x20, v)`) expanded to `and/bic/and/orr` instead of `bsl` on aarch64 - minor, not investigated further.
