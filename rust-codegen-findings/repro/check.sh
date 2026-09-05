#!/bin/bash
# Automated signature checks for the codegen findings.
# usage: ./check.sh <toolchain>      e.g. ./check.sh nightly   or   ./check.sh 1.100.0
# Prints REPRODUCES when the bad pattern is present, fine when it is not.
tc=$1
fn() { awk -v f="$1:" '$0==f{p=1;next} p&&/^\t\.size|^\.Lfunc_end/{p=0} p' "$2"; }
build() { rustc +"$tc" -O -C panic=abort --crate-type=lib --emit=asm --edition 2021 "$@" 2>/dev/null; }
build -C target-cpu=x86-64-v3 repro.rs -o x86.s || echo "repro.rs failed to build on $tc"
build --target aarch64-unknown-linux-gnu repro.rs -o arm.s || echo "aarch64 build failed (rustup target add aarch64-unknown-linux-gnu)"
build -C target-cpu=x86-64-v3 repro_simd.rs -o x86s.s
build repro_simd.rs -o sse2.s
echo "== $tc: $(rustc +"$tc" -vV | grep -E '^release' | cut -d' ' -f2), $(rustc +"$tc" -vV | grep LLVM)"
r() { printf '  %-52s %s\n' "$1" "$2"; }
bad() { [ "$1" -gt "$2" ] && echo REPRODUCES || echo fine; }
c=$(fn f1_lib x86.s | grep -c cmov);               r "1 is_ascii_alphanumeric x86 cmov count" "$c $(bad $c 0)"
c=$(fn f1_lib arm.s | grep -c csel);               r "1 is_ascii_alphanumeric aarch64 csel count" "$c $(bad $c 0)"
c=$(fn f1_hex x86.s | grep -c cmov);               r "1 is_ascii_hexdigit x86 cmov count" "$c $(bad $c 0)"
c=$(fn f1_punct x86.s | grep -c cmov);             r "1 is_ascii_punctuation x86 cmov count" "$c $(bad $c 0)"
c=$(fn f2_any_zero x86.s | grep -c 'ymm');         r "2 to_ne_bytes any==0 x86 ymm uses" "$c $(bad $c 0)"
c=$(fn f2_any_zero arm.s | grep -cE 'v[0-9]+\.');  r "2 to_ne_bytes any==0 aarch64 NEON ops" "$c $(bad $c 4)"
c=$(fn f2_varint_tail x86.s | grep -c 'vpcmpgtq'); r "2 varint_tail x86 vpcmpgtq" "$c $(bad $c 0)"
c=$(fn f2_varint_tail arm.s | grep -c 'cmhi');     r "2 varint_tail aarch64 cmhi" "$c $(bad $c 0)"
c=$(fn f2_unpack x86.s | grep -cE 'vpsllv|vpmull'); r "2 [bool;8] unpack x86 vpsllv/vpmull" "$c $(bad $c 0)"
c=$(fn f2_any_eq arm.s | grep -c 'ushl');          r "2 any(b==n) aarch64 ushl" "$c $(bad $c 0)"
c=$(fn f4_lex8 x86.s | grep -cE 'sets|setg');      r "4 [u8;8]::cmp x86 second signum (sets/setg)" "$c $(bad $c 0)"
c=$(fn f4_lex8 arm.s | grep -c 'sxtw');            r "4 [u8;8]::cmp aarch64 sxtw+recompare" "$c $(bad $c 0)"
c=$(grep -c 'call.*classify' x86.s);               r "5 classify calls remaining x86" "$c $(bad $c 0)"
c=$(grep -c 'bl.*classify' arm.s);                 r "5 classify calls remaining aarch64" "$c $(bad $c 0)"
c=$(fn f6_eq x86.s | grep -c 'jne');               r "6 derive(PartialEq) 4xu8 x86 branches" "$c $(bad $c 0)"
c=$(fn f6_eq arm.s | grep -c 'csel');              r "6 derive(PartialEq) 4xu8 aarch64 csel" "$c $(bad $c 0)"
c=$(fn f7_abs x86.s | grep -cE '^\tj');            r "7 checked_abs x86 jumps" "$c $(bad $c 0)"
c=$(fn f8_is_op x86.s | grep -c 'jmpq');           r "8 is_op x86 jump table" "$c $(bad $c 0)"
c=$(fn f9_cmp x86.s | grep -c 'cmpl');             r "9 derived Ord x86 cmpl count (3 fields)" "$c $(bad $c 3)"
if [ -s x86s.s ]; then
  c=$(fn f3_lib x86s.s | grep -c 'vmovmskpd');     r "3 mask64x2::to_bitmask x86 vmovmskpd" "$c $([ "$c" -eq 0 ] && echo REPRODUCES || echo fine)"
  c=$(fn f3_direct x86s.s | grep -c 'vmovmskpd');  r "3   (direct intrinsic vmovmskpd, expect 1)" "$c"
  c=$(fn f3_lib4 x86s.s | grep -c 'vmovmskpd');    r "3 f64x4 simd_lt().to_bitmask x86 vmovmskpd" "$c $([ "$c" -eq 0 ] && echo REPRODUCES || echo fine)"
  c=$(fn f3_lib32 x86s.s | grep -c 'ymm');         r "3 mask32x4::to_bitmask x86 touches ymm" "$c $(bad $c 0)"
  c=$(fn f3_lib sse2.s | grep -c 'movmskpd');      r "3 mask64x2::to_bitmask SSE2 movmskpd" "$c $([ "$c" -eq 0 ] && echo REPRODUCES || echo fine)"
else
  echo "  3 portable-simd cases skipped (need nightly)"
fi
