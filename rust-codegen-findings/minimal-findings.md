# Minimal reproducers and disjointness of the nine findings

All observations below were made on `rustc 1.100.0-nightly (0ed41eb41 2026-09-04)` (LLVM 23.1.1),
x86-64-v3 unless stated. "Verified" means the toggle was actually run;
"inferred" means the mechanism is established from IR/pass evidence but the specific flag was not run.
Run `repro/check.sh nightly` to re-confirm every signature; add the flag from the table to the
`build` line in the script to confirm a single toggle.

## Minimal reproducers

Each is a single function; no helper types unless the finding is about the type.

| # | Minimal source | Bad signature (x86-64-v3) |
|---|----------------|---------------------------|
| 1 | `pub fn f(c: u8) -> bool { c.is_ascii_alphanumeric() }` | 2x `cmov`, 15 instr (should be 9, no cmov) |
| 2a | `pub fn f(x: u64) -> bool { x.to_ne_bytes().iter().any(\|&b\| b == 0) }` | `ymm` registers, `vpcmpeqq`, 28 instr |
| 2b | `pub fn f(x: u64) -> u32 { (x >= 1 << 35) as u32 + (x >= 1 << 42) as u32 + (x >= 1 << 49) as u32 + (x >= 1 << 56) as u32 }` | `vpcmpgtq ymm` (stable: 4 scalar cmp/sbb) |
| 3 | `pub fn f(v: mask64x2) -> u64 { v.to_bitmask() }` | no `vmovmskpd`; `vpcmpgtq/vpackssdw/vpermq/vmovmskps` |
| 4 | `pub fn f(a: &[u8; 8], b: &[u8; 8]) -> Ordering { a.cmp(b) }` | `sets`/`setg`/`subb` after `seta`/`sbbb` |
| 5 | 10-arm `#[inline] fn classify(c: u8) -> Tok` + **two** callers (one caller gets the last-call bonus and is inlined) | `call classify` survives |
| 6 | `#[derive(PartialEq)] struct P(u8,u8,u8,u8); pub fn f(a: P, b: P) -> bool { a == b }` | two `jne`, three compares |
| 7 | `pub fn f(x: i32) -> Option<i32> { x.checked_abs() }` | `jo L1; L2: ... L1: jmp L2` |
| 8 | `pub fn f(c: u8) -> bool { matches!(c, b'+' \| b'-' \| b'*' \| b'/' \| b'%' \| b'<' \| b'>' \| b'=' \| b'!' \| b'&' \| b'\|' \| b'^' \| b'~') }` | `jmpq *%rcx`, 94-entry table |
| 9 | `#[derive(PartialOrd, Ord, PartialEq, Eq)] struct P(u32, u32); pub fn f(a: &P, b: &P) -> Ordering { a.cmp(b) }` | `cmpl` issued twice for the first field |

Notes on minimality that were actually tested:

* 1: `is_ascii_alphabetic` (two ranges) is fine; three ranges or-ed are needed. `u8` and `char` both reproduce.
* 2a: the `u32` variant is scalar; eight bytes are needed. `contains(&0)` is scalar (different iterator shape), so `any` with a closure is the minimal form.
* 2b: five terms were used in the report; the vectorised IR is `<4 x i64>`, so four terms is the floor.
* 3: `mask32x4` reproduces in the weaker form (ymm + vzeroupper); `mask64x2` is the clearest.
* 4: `[u8; 4]` and `[u8; 16]` reproduce; `[u8; 2]` takes a different path (`sub` then signum, not `ucmp`), so 8 is the canonical size.
* 5: exactly the threshold matters: ten cases spanning `9..=95` cost ~445 > 325. Fewer/denser cases inline.
* 6: by value is essential; by reference is merged by MergeICmps.
* 7: `checked_neg` alone (`x.checked_neg()`) does not show it; the `is_negative()` select plus the `unlikely` select are both needed.

## Disjointness: which optimisation path each finding lives on

| # | Pass / stage responsible | Evidence | Toggle that isolates it | Status |
|---|--------------------------|----------|-------------------------|--------|
| 1 | SimplifyCFG speculation + InstCombine select simplification (middle end, LLVM 23 change) | same pre-opt IR: opt 22.1 -> `or` of two range checks; opt trunk -> `select`; `-print-changed` shows the select born after SimplifyCFG and surviving InstCombine | rewrite as one `matches!` (source-level); opt 22.1 vs trunk | verified |
| 2 | SLPVectorizer cost model (middle end) | final IR contains `<8 x i64>` / `<4 x i64>` ops; opt 22.1 keeps 2b scalar, trunk vectorises | `-C llvm-args=-vectorize-slp=false` | inferred (IR is unambiguous; flag not run) |
| 3 | portable-simd library (`resize::<8>` before `simd_bitmask`) | calling `simd_bitmask` directly gives `vmovmskpd` on the same compiler | source-level: drop the resize | verified |
| 4 | Pass ordering: `ExpandMemCmpPass` in late `OptimizePM` after the last InstCombine | opt trunk folds the same IR to one `ucmp` when it sees it; the real pipeline never does | adding an InstCombine after ExpandMemCmp (pipeline change); no user flag | verified mechanism |
| 5 | Inline cost model (`onFinalizeSwitch` jump-table charge) | `print<inline-cost>` threshold 325 at every site; `-inline-threshold=500` inlines everything | `-C llvm-args=-inline-threshold=500` | verified |
| 6 | SimplifyCFG `FoldBranchToCommonDest` bonus-instruction budget + MergeICmps only seeing loads | rustc pre-opt IR through opt trunk keeps branches; clang's IR merges | `-C llvm-args=-bonus-inst-threshold=4` (expected to flatten to `and` chain) | inferred |
| 7 | x86 `SelectOptimize` (backend) turning a profiled `select ..., undef` into a branch | llc trunk with `!prof` -> `jno` to fallthrough; without `!prof` -> clean | `-C llvm-args=-enable-select-optimize=false` (expected) | verified mechanism, flag not run |
| 8 | x86 switch lowering / `SwitchToLookupTable` refusing >64-entry i1 tables | aarch64 emits bit test + 2 compares from the same IR; clang C `switch` same | `-C llvm-args=-min-jump-table-entries=...` or `-max-jump-table-size` | inferred |
| 9 | Tail merging / flag reuse in x86 ISel (backend) | aarch64 has no double compare; `a.cmp(&b).then(..)` is fine -> depends on block structure from `match Ordering::Equal` in derive | none identified | not isolated |

Overlaps to be aware of:

* 2a, 2b and the `[bool; 8]` unpack share the SLP cost model and should be one LLVM issue with several inputs. They are distinct from 3: finding 3 is the *library* widening the vector; the backend then does the right thing for the IR it is given.
* 5's second-order jump table (after forcing inlining) and 8 share x86 switch lowering; 5 itself is the inline cost model and is independent of 8.
* 1 and 6 both involve SimplifyCFG but in different transforms (speculation into `select` vs. `FoldBranchToCommonDest` budget) and 1 regressed while 6 did not, so they are separate.
* 7 regressed together with 1 and 2b in LLVM 23 but is a backend pass; the three regressions are on three different paths.
