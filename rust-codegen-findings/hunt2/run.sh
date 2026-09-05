#!/bin/bash
# Hunt 2 runner. Emits filtered asm for every function in h_loops.rs and h_scalar.rs on
# x86-64-v3, baseline x86-64 and aarch64, for one or more toolchains, and prints per-function
# instruction counts side by side so regressions and outliers stand out before reading asm.
#
#   ./run.sh nightly            # one toolchain
#   ./run.sh nightly stable     # counts for both, plus a diff column
#
# Output: out/<tc>.<file>.<target>.s (asm) and a table on stdout.
set -u
cd "$(dirname "$0")"
mkdir -p out
FILTER='^\s*\.(cfi|p2align|size|type|section|text|file|ident|addrsig|globl|hidden|weak|loc|note|prefalign|att|byte|quad|zero|long|word|short|hword|xword|ascii|asciz)|^\s*$|^\s*#|^\s*//|^\.L[a-z_]+[0-9_]*:$|^\.Lanon'
build() { # tc file tag flags...
  local tc=$1 f=$2 tag=$3; shift 3
  rustc "+$tc" -O -C panic=abort --crate-type=lib --emit=asm --edition 2021 "$@" "$f.rs" -o "out/$tc.$f.$tag.raw.s" 2>"out/$tc.$f.$tag.err" \
    && grep -vE "$FILTER" "out/$tc.$f.$tag.raw.s" > "out/$tc.$f.$tag.s" \
    || { echo "build failed: $tc $f $tag (see out/$tc.$f.$tag.err)"; return 1; }
}
counts() { # asm file -> "fn count" lines (count = instructions between label and next label/size)
  awk '/^[A-Za-z_][A-Za-z_0-9]*:$/{ if (name!="") print name, n; name=substr($0,1,length($0)-1); n=0; next }
       /^\t[a-z]/{ n++ } END{ if (name!="") print name, n }' "$1" | sort
}
for f in ${FILES:-h_loops h_scalar}; do
  for tc in "$@"; do
    build "$tc" "$f" v3   -C target-cpu=x86-64-v3
    build "$tc" "$f" sse2
    build "$tc" "$f" arm  --target aarch64-unknown-linux-gnu
  done
  for tag in v3 sse2 arm; do
    echo; echo "=== $f / $tag   (instruction count per function; ${*})"
    first=$1
    counts "out/$first.$f.$tag.s" > "out/.c1"
    if [ $# -ge 2 ]; then
      counts "out/$2.$f.$tag.s" > "out/.c2"
      join -a1 -a2 -e '?' -o '0,1.2,2.2' "out/.c1" "out/.c2" | awk '{ d=($2!="?"&&$3!="?")?$2-$3:"?"; printf "  %-24s %5s %5s %+5s\n", $1, $2, $3, d }'
    else
      awk '{ printf "  %-24s %5s\n", $1, $2 }' "out/.c1"
    fi
  done
done
echo
echo "Suspects to open first: any function whose count differs between toolchains, and any function"
echo "in h_loops.rs whose v3 asm contains 'call' (memset/memcpy is fine; anything else is a missed inline),"
echo "or whose sse2/v3 asm mixes 'vpinsr'/'vpextr'/'pinsr' with scalar shifts (SLP gather), or whose"
echo "aarch64 asm contains 'str b0, [sp' (vector->GPR through the stack)."
