#!/bin/bash
# Build diff_test.rs with nightly and stable, natively and for aarch64 (qemu), and diff per-function hashes.
set -u; cd "$(dirname "$0")"; mkdir -p out
it=${1:-20000}
for tc in nightly stable; do
  rustc +$tc -O -C panic=abort --edition 2021 -C target-cpu=x86-64-v3 diff_test.rs -o out/dt_$tc.v3 || exit 1
  rustc +$tc -O -C panic=abort --edition 2021 diff_test.rs -o out/dt_$tc.sse2 || exit 1
  rustc +$tc -O -C panic=abort --edition 2021 --target aarch64-unknown-linux-musl -C linker=rust-lld -C link-self-contained=yes -C target-feature=+crt-static diff_test.rs -o out/dt_$tc.arm || exit 1
  ./out/dt_$tc.v3 $it > out/dt_$tc.v3.txt; ./out/dt_$tc.sse2 $it > out/dt_$tc.sse2.txt; qemu-aarch64 ./out/dt_$tc.arm $it > out/dt_$tc.arm.txt
done
for t in v3 sse2 arm; do echo "== nightly vs stable, $t"; diff out/dt_nightly.$t.txt out/dt_stable.$t.txt && echo "  identical"; done
for tc in nightly stable; do echo "== $tc: v3 vs sse2 vs arm"; diff out/dt_$tc.v3.txt out/dt_$tc.sse2.txt && diff out/dt_$tc.v3.txt out/dt_$tc.arm.txt && echo "  identical"; done
