#!/bin/bash
# Build the correctness harness natively and for aarch64, run the aarch64 binary under qemu-user.
# Needs: qemu-aarch64 (apt install qemu-user) and either a cross gcc (gcc-aarch64-linux-gnu) or the
# aarch64-unknown-linux-musl rust target, which links statically with rust-lld and needs no sysroot.
set -eu
cd "$(dirname "$0")"
tc=${1:-nightly}
echo "== native ($(uname -m))"
rustc +"$tc" -O -C panic=abort --edition 2021 qemu_test.rs -o t_native
./t_native
echo "== aarch64 under qemu"
if ! command -v qemu-aarch64 >/dev/null; then echo "qemu-aarch64 not found: apt install qemu-user"; exit 2; fi
if rustup target list --installed --toolchain "$tc" | grep -q aarch64-unknown-linux-musl; then
  rustc +"$tc" -O -C panic=abort --edition 2021 --target aarch64-unknown-linux-musl \
    -C linker=rust-lld -C link-self-contained=yes -C target-feature=+crt-static qemu_test.rs -o t_arm
  qemu-aarch64 ./t_arm
elif command -v aarch64-linux-gnu-gcc >/dev/null; then
  rustc +"$tc" -O -C panic=abort --edition 2021 --target aarch64-unknown-linux-gnu \
    -C linker=aarch64-linux-gnu-gcc qemu_test.rs -o t_arm
  qemu-aarch64 -L /usr/aarch64-linux-gnu ./t_arm
else
  echo "no aarch64 linker: rustup target add aarch64-unknown-linux-musl --toolchain $tc   (or apt install gcc-aarch64-linux-gnu)"; exit 2
fi
echo "== asm signatures"
./check.sh "$tc"
