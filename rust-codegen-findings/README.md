# Rust codegen findings (hand-over)

Nine unreported places where rustc + LLVM 23 emit clearly worse machine code than they should, found by compiling
~350 small functions and diffing against stable 1.94 (LLVM 21), clang/opt/llc trunk and opt 21.1/22.1.

* `codegen-findings.md` - the report: reproducer, assembly for both targets, root cause, regression status, duplicate check.
* `minimal-findings.md` - one-function reproducer per finding and the disjointness matrix (which pass each lives on, which flag isolates it, verified vs inferred).
* `repro/repro.rs`, `repro/repro_simd.rs` - consolidated reproducers (`repro_simd.rs` needs nightly).
* `repro/check.sh <toolchain>` - builds for x86-64-v3, baseline x86-64 and aarch64 and prints REPRODUCES/fine per finding.
* `repro/qemu_test.rs`, `repro/qemu.sh` - correctness harness (exhaustive u8, 2M random u64 cases) run natively and under qemu-aarch64.
* `hunt2/` - a prepared second hunt over loop, division, float, enum-niche, ABI and parsing paths. Not yet run; `hunt2/run.sh nightly stable` prints per-function instruction counts with a nightly-vs-stable diff.

Toolchains used: `rustc 1.100.0-nightly (0ed41eb41 2026-09-04)` with LLVM 23.1.1; `rustc 1.94.1` with LLVM 21.1.8.
Flags: `-O -C panic=abort --crate-type=lib --emit=asm`, x86 with `-C target-cpu=x86-64-v3`, aarch64 generic.

Where each finding belongs: LLVM for 2, 4, 5, 7, 8, 9 and the InstCombine half of 1; rust-lang/rust for the
library rewrite that avoids 1; rust-lang/portable-simd for 3; 6 is arguable (rustc IR shape vs LLVM budget).

Everything here was authored by Claude in an interactive session. Both rust-lang and LLVM require disclosure of
LLM involvement; do not paste this text into upstream issues or PRs without rewriting and disclosing.

Update 2026-09-05: everything above was re-run on the same nightly; see `results/run-2026-09-05.md` for
the correctness verdict (no miscompile found), a correction to finding 7 (it is CodeGenPrepare's
select-to-branch, and `check.sh` had a tab bug that hid it), the second-hunt results and one new AArch64 finding.
