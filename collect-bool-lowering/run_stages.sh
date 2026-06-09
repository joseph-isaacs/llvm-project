#!/usr/bin/env bash
# Lower collect_bool.O0.ll through trunk LLVM, dumping the IR at each
# pipeline milestone that matters for the bit-packing lowering.
set -euo pipefail
cd "$(dirname "$0")"
OPT=../build/bin/opt
LLC=../build/bin/llc

$OPT --version | head -2

# Input IR: emitted by rustc without optimization, two target variants.
rustc --crate-type=lib --edition 2021 -C opt-level=0 -C debuginfo=0 \
  -C panic=abort -C debug-assertions=off \
  --emit=llvm-ir -o collect_bool.O0.ll collect_bool.rs
rustc --crate-type=lib --edition 2021 -C opt-level=0 -C debuginfo=0 \
  -C panic=abort -C debug-assertions=off -C target-cpu=x86-64-v3 \
  --emit=llvm-ir -o collect_bool.O0.v3.ll collect_bool.rs

# Stage 1: inlining + SROA (mem2reg) + early instcombine/simplifycfg.
# This is the "canonical scalar loop" form the loop passes see.
$OPT -S collect_bool.O0.ll \
  -passes='cgscc(inline),function(sroa<modify-cfg>,early-cse,simplifycfg,instcombine,simplifycfg)' \
  -o stage1.scalar-loops.ll

# Stages 2-3: snapshot the function inside the real default<O3> pipeline
# after the passes that do the heavy lifting. (Printing must go to a
# separate invocation: -print-after on the same run that writes -o can
# leave dangling metadata in the output module.)
$OPT -S collect_bool.O0.ll -passes='default<O3>' \
  -print-after=loop-vectorize,slp-vectorizer,instcombine \
  -filter-print-funcs=collect_bool \
  -o /dev/null 2> pipeline-dumps.txt

# Record which passes changed the function, in order.
$OPT -S collect_bool.O0.ll -passes='default<O3>' \
  -print-changed=quiet -filter-print-funcs=collect_bool -o /dev/null \
  2> changed-passes.txt || true
grep -o 'IR Dump After [^ ]*' changed-passes.txt | sort | uniq -c | sort -rn > changed-pass-summary.txt

# Stage 4: final O3 IR, baseline x86-64 and x86-64-v3 (AVX2).
$OPT -S collect_bool.O0.ll    -passes='default<O3>' -o stage4.final-O3.ll
$OPT -S collect_bool.O0.v3.ll -passes='default<O3>' -o stage4.final-O3.v3.ll

# Stage 5: machine code.
$LLC -O3 -mcpu=x86-64    stage4.final-O3.ll    -o stage5.x86-64-baseline.s
$LLC -O3 -mcpu=x86-64-v3 stage4.final-O3.v3.ll -o stage5.x86-64-v3-avx2.s

echo "--- stage sizes ---"
wc -l stage1.scalar-loops.ll stage4.final-O3.ll stage4.final-O3.v3.ll stage5.*.s pipeline-dumps.txt
