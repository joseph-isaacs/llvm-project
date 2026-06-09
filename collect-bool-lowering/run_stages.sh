#!/usr/bin/env bash
# Lower collect_bool.O0.ll through trunk LLVM, dumping the IR at each
# pipeline milestone that matters for the bit-packing lowering.
set -euo pipefail
cd "$(dirname "$0")"
OPT=../build/bin/opt
LLC=../build/bin/llc

$OPT --version | head -2

# Stage 1: inlining + SROA (mem2reg) + early instcombine/simplifycfg.
# This is the "canonical scalar loop" form the loop passes see.
$OPT -S collect_bool.O0.ll \
  -passes='cgscc(inline),function(sroa<modify-cfg>,early-cse,simplifycfg,instcombine,simplifycfg)' \
  -o stage1.scalar-loops.ll

# Stage 2+3: run the real default<O3> pipeline over the original -O0 IR,
# snapshotting the function after the passes that do the heavy lifting.
$OPT -S collect_bool.O0.ll -passes='default<O3>' \
  -print-after=loop-vectorize,slp-vectorizer,instcombine \
  -filter-print-funcs=collect_bool \
  -o stage4.final-O3.ll 2> pipeline-dumps.txt

# Also record which passes changed the function, in order.
$OPT -S collect_bool.O0.ll -passes='default<O3>' \
  -print-changed=quiet -filter-print-funcs=collect_bool -o /dev/null \
  2> changed-passes.txt || true
grep -o 'IR Dump After [^ ]*' changed-passes.txt | sort | uniq -c | sort -rn > changed-pass-summary.txt

# Stage 5: machine code, baseline x86-64 (SSE2) and x86-64-v3 (AVX2).
$LLC -O3 -mcpu=x86-64    stage4.final-O3.ll -o stage5.x86-64-baseline.s
$LLC -O3 -mcpu=x86-64-v3 stage4.final-O3.ll -o stage5.x86-64-v3-avx2.s

echo "--- stage sizes ---"
wc -l stage1.scalar-loops.ll stage4.final-O3.ll stage5.*.s pipeline-dumps.txt
