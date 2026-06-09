# collect_bool bit-packing: IR lowering on LLVM trunk

Lowering of an arrow-rs-style `collect_bool` (bit-packing a large `u8`
boolean array into `u64` bitset words) through LLVM trunk
(`3a522ff09`, version 23.0.0git), built in `../build` (Release, X86 only).

The Rust source (`collect_bool.rs`) has two variants of the same nested
loop — outer loop per 64-bit word, inner loop
`packed |= ((src[chunk*64 + bit] != 0) as u64) << bit`:

- `collect_bool`: ordinary indexed access (bounds checks).
- `collect_bool_unchecked`: `get_unchecked`, matching how arrow-rs call
  sites actually drive `MutableBuffer::collect_bool` closures.

rustc 1.94.1 (LLVM 21) emits the unoptimized IR (`--emit=llvm-ir
-C opt-level=0`); no cargo build is involved. Trunk `opt`/`llc` do all
optimization. Regenerate everything with `./run_stages.sh`.

## Files

| File | Contents |
|------|----------|
| `collect_bool.O0.ll` | rustc -O0 IR (input to trunk opt) |
| `collect_bool.O0.v3.ll` | same, with `target-cpu=x86-64-v3` attributes |
| `stage1.scalar-loops.ll` | after inline + SROA + early instcombine |
| `pipeline-dumps.txt` | function snapshots inside `default<O3>` (pre/post LoopVectorize, SLP, instcombine) |
| `changed-pass-summary.txt` | passes that changed `collect_bool`, by count |
| `stage4.final-O3.ll` / `.v3.ll` | final `default<O3>` IR |
| `stage5.x86-64-baseline.s` / `stage5.x86-64-v3-avx2.s` | llc -O3 output |

## Findings

1. **The packing loop is vectorized by LoopVectorize, not SLP.** The
   inner 64-iteration loop becomes a vector or-reduction:
   `or(shl(zext(icmp ne <N x i8> %bytes, 0) to <N x i64>), %vec.ind)`
   accumulated into vector phis, reduced with
   `llvm.vector.reduce.or` at the loop exit. SLP runs but changes nothing.

2. **Bounds checks are never proven redundant.** In the checked variant,
   `chunk*64 + bit < src.len()` always holds (`chunks = len/64`), but
   neither IndVarSimplify nor ConstraintElimination eliminates the check.
   LoopVectorize instead treats the panic exit as an early exit and
   vectorizes only a prefix: per 64-bit word it runs 15 vector iterations
   (60 elements, VF=2 x IC=2 at SSE2) plus a 4-iteration scalar tail that
   still carries the bounds check, plus per-chunk umax/umin trip-count
   arithmetic.

3. **The unchecked variant lowers cleanly.** Constant trip count 64, no
   scalar tail, no panic blocks in the loop nest. At SSE2 it stays a
   16-iteration `<2 x i64>` loop; with `target-cpu=x86-64-v3` LoopVectorize
   picks VF=4 x IC=4 and LoopUnroll+InstCombine fully unroll the chunk into
   straight-line code where each `shl zext(cmp), <const idx>` becomes
   `select <4 x i1>, 0, <1,2,4,8,...>` against precomputed mask constants
   (`vpmovzxbq` + `vpcmpgtq` + `vpand` + `vpor` tree in the asm).

4. **Missed optimization: no movemask.** The ideal lowering of
   "compare 32 bytes to zero, take the sign-bit mask" is
   `vpcmpeqb`+`vpmovmskb` (~10 instructions per 64 bytes). Trunk emits
   ~94 instructions per 64-byte chunk on AVX2 because the backend never
   matches the or-reduction-of-shifted-bools idiom to MOVMSK.
