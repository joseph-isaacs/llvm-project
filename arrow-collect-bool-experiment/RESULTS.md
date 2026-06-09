# arrow-rs `collect` → BooleanArray: -O3 results at branch head

Experiment: take the basic (frontend-level) LLVM IR for arrow-rs
`MutableBuffer::collect_bool` — the routine behind both
`Vec<bool>.into_iter().collect::<BooleanArray>()` and the `arrow_ord::cmp`
kernels — and run it through `opt -passes='default<O3>' -mcpu=x86-64-v3` +
`llc` built from `claude/movemask-03-instcombine-bool-mask-fold`
(a4101e857, based on main 3a522ff09).

The inner idiom, per 64-element chunk:

    packed |= (f(i) as u64) << bit_idx;     // bit_idx = 0..64

with `f(i)` = bool load (case 1) or `src[i] > k` icmp (case 2).
Basic IR produced by rustc 1.94 with `-C no-prepopulate-passes`
(`basic.ll`, from `arrow_collect_bool.rs`).

## Results at branch head (identical to main — the fold never fires here)

| case | O3 result | per 64 elements | optimal reference |
|---|---|---|---|
| bool vec (`collect_bool_from_bool_vec`) | inner loop fully unrolled to a **64-step scalar shl/or chain** | ~197 scalar instructions | **10** (2× `vpcmpeqb`+`vpmovmskb`) |
| i32 icmp (`collect_bool_from_i32_gt`) | loop-vectorized at **VF=2, IC=2** with `shl <2 x i64>` by a *runtime* vector induction, `reduce.or.v2i64` | 16 iterations × ~20 insns ≈ 320 dynamic | **36** (8× `vpcmpgtd`, 6 packs, 2× `vpmovmskb`) |

`diff` of O3 output between branch head and main is empty for both
functions: **not optimal, and the new InstCombine fold does not change the
result for arrow's scalar source loops.** (System LLVM 18 produces the same
two failure shapes, so this is a long-standing miss, llvm/llvm-project#121691.)

## Why the fold can't fire (probes)

* **Probe A** (`-vectorize-loops=false`): the icmp case then gets
  runtime-unrolled only 4×, shifts stay variable — SLP has nothing to match.
  The blocker is that LV claims the 64-trip loop at VF=2 *before* full
  unrolling can expose constant shift amounts; the resulting
  `shl <2 x i64> %zext, %vec.ind` has runtime weights, which
  `matchBitPositionWeightedMask` (correctly) cannot match.

* **Probe B** (`chain64.ll`): a fully-unrolled, uniform-i64 chain with
  constant shifts and an explicit `icmp` folds **perfectly**, even at width
  64: `load <64 x i32>` → `icmp sgt <64 x i32>` → `bitcast <64 x i1> to
  i64` → 36-instruction asm. (This works on main too — it's SLP's
  llvm/llvm-project#181940 path; the destination shape is reachable and
  optimal.)

* **Probe C** (`chain64_rustc_form.ll`): same chain but in rustc's *bool*
  form — `load i8 !range [0,2)` + `trunc nuw i8 to i1` instead of `icmp ne`
  — collapses into an SLP salad (`<3 x i8>` loads, giant shuffles,
  `reduce.or.v32i64`). InstCombine folds the `trunc`+`zext` into a plain
  `zext i8`, so **no `<N x i1>` mask ever materializes** and neither SLP's
  bitcast trick nor the branch's fold has anything to bite on. In the real
  function it's worse: post-unroll InstCombine narrows lanes 0–7 to `i8`
  ops, producing a mixed-width chain that stays fully scalar.

## Where the branch *does* win at width 64

Already-vectorized IR (what `std::simd::Mask::to_bitmask`-style frontends
emit), `vecir64.ll`:

    reduce.or(shl (zext <64 x i1> %m to <64 x i64>), <0,1,...,63>)

* main:   stays `reduce.or.v64i64` over 512 bytes of vector — catastrophic.
* branch: folds to `bitcast <64 x i1> %m to i64` — optimal.

## Conclusions

1. The branch's fold is correct and valuable for vector-IR inputs (incl.
   width 64), but arrow-rs's scalar `collect_bool` loops never reach a
   matchable shape at -O3.
2. Two distinct upstream gaps remain for arrow-rs:
   * **icmp case**: LV cost model picks VF=2 on the bit-pack reduction
     instead of leaving it to full-unroll+SLP (or vectorizing the `shl` by
     induction as constant weights per part). A phase-ordering/cost issue.
   * **bool case**: rustc's `trunc nuw`-of-`!range` bool representation
     loses the `<N x i1>` mask; a fold recognizing `zext i8` with known
     range [0,2) weighted by bit positions (inserting the `icmp ne` itself)
     would unlock it — a natural extension of
     `matchBitPositionWeightedMask`.

## Files

* `arrow_collect_bool.rs`, `basic.ll` — source + basic IR
* `o3-branch.ll`, `o3-branch.s` — O3 + llc at branch head (== main)
* `chain64.ll`, `o3-chain64.ll`, `o3-chain64.s` — probe B + optimal reference asm
* `chain64_rustc_form.ll`, `o3-chain64-rustc-form.ll` — probe C
* `vecir64.ll`, `o3-vecir64-branch.ll`, `o3-vecir64-main.ll` — branch value-add

Reproduce: `opt -passes='default<O3>' -mcpu=x86-64-v3 -S basic.ll | llc -mcpu=x86-64-v3`
