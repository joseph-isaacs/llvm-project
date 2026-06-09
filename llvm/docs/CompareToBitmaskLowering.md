# Compare → Bitmask ("movemask") Lowering

This document explains the two transformations that turn a *vectorized
compare-to-bitmask* (a.k.a. **movemask** / bit-pack) idiom into efficient code:

1. **VectorCombine** — an IR→IR fold that recognizes the idiom the vectorizers
   leave behind and rewrites it to a single `bitcast <N x i1> to iN`
   (`foldReduceOfBoolMaskWeights`).
2. **AArch64 ISel lowering** — a backend fix so that
   `bitcast <N x i1> to iN` from a wide (>128-bit) source lowers entirely in
   registers instead of bouncing through the stack
   (`vectorToScalarBitmask` narrowing).

The two are independent: (1) produces the canonical `bitcast`, (2) makes the
backend lower that `bitcast` well. Together they take

```c
// pack 64 booleans (v[i] != 0) into the bits of a u64 word
for (b = 0; b < 64; ++b)
  word |= (uint64_t)(v[b] != 0) << b;
```

from a literal `1<<b` scatter to a single movemask (x86 `vpmovmskb`; AArch64
`cmeq`/`bic`/`addp`).

---

## Background: what the vectorizers emit

The SLP vectorizer turns the unrolled pack into a reduction over per-lane bit
weights, but stops there (see llvm/llvm-project#121691):

```llvm
; %p points at 8 bytes; we want bit i = (p[i] != 0)
  %0 = load <8 x i8>, ptr %p                       ; load 8 bytes as a vector
  %1 = icmp ne <8 x i8> %0, zeroinitializer        ; %1 = <8 x i1> mask, lane i = (p[i] != 0)
  %2 = zext <8 x i1> %1 to <8 x i8>                ; widen each lane to 0/1
  %3 = shl <8 x i8> %2, <i8 0, i8 1, ..., i8 7>    ; lane i -> value (0 or 1<<i)
  %4 = call i8 @llvm.vector.reduce.or.v8i8(<8 x i8> %3)  ; OR all lanes = the bitmask
  ret i8 %4
```

The `reduce.or(shl(zext(mask)))` here is algebraically a movemask, but LLVM has
no general recognizer, so the backend keeps the literal `1<<i` scatter and is
several times slower than a hand-written movemask. That is what Transformation 1
fixes.

(The LoopVectorizer, by contrast, refuses the `word |= (v[i]!=0) << i` loop
outright — the shift is induction-dependent, so it is not one of its reduction
recurrences — so there is no vectorized IR to rewrite; the loop idiom is reached
by SLP on a strip-mined inner block.)

---

## Transformation 1 — VectorCombine: recognize the idiom

`VectorCombine::foldReduceOfBoolMaskWeights` matches any of the equivalent
shapes the vectorizers emit and rewrites them to `zext(bitcast <N x i1> to iN)`.

### The identity

For an `<N x i1>` mask `%m`, on a little-endian target:

```
reduce.or( select %m, <1, 2, 4, ..., 2^(N-1)>, 0 )   ==   zext(bitcast %m to iN)
```

Each lane `i` contributes either `0` or `2^i` — **disjoint single bits** — so
`or` = `add` = `xor` (no carries, no overlap), and `bitcast <N x i1> to iN`
already maps lane `i` to bit `i` on little-endian. That is exactly a movemask.

### Annotated input → output

**Before** (the `select` form; the `shl`/`and`/`mul` forms are equivalent):

```llvm
define i8 @select_form(<8 x i1> %m) {
  ; --- build per-lane bit weights: lane i -> (m[i] ? 2^i : 0) ---
  %sel = select <8 x i1> %m,
                <8 x i8> <i8 1, i8 2, i8 4, i8 8, i8 16, i8 32, i8 64, i8 -128>,
                <8 x i8> zeroinitializer
  ; --- OR the disjoint lane bits together into the scalar bitmask ---
  %r = call i8 @llvm.vector.reduce.or.v8i8(<8 x i8> %sel)
  ret i8 %r
}
```

**After**:

```llvm
define i8 @select_form(<8 x i1> %m) {
  ; the whole select+reduce collapses to a movemask: lane i -> bit i
  %r = bitcast <8 x i1> %m to i8
  ret i8 %r
}
```

When the reduction's element type is wider than `N` bits, the result is
`zext` to that type, e.g. for `reduce.or` over `<8 x i32>`:

```llvm
  %1 = bitcast <8 x i1> %m to i8     ; pack the 8 lanes into 8 bits
  %r = zext i8 %1 to i32             ; widen to the reduction's element type
```

### Forms matched

All four producer shapes reduce to the same `<N x i1>` mask:

```llvm
reduce.{or,add,xor} ( select %m, <1,2,4,...,2^(N-1)>, 0 )   ; canonical
reduce.{or,add,xor} ( shl (zext %m), <0,1,2,...,N-1> )      ; zext is 0/1, <<i gives 2^i
reduce.{or,add,xor} ( and (sext %m), <1,2,4,...> )          ; sext is 0/-1, & 2^i gives 2^i
reduce.{or,add,xor} ( mul (zext %m), <1,2,4,...> )          ; (0/1) * 2^i gives 2^i
```

### Guards

* **Little-endian only.** `bitcast <N x i1> to iN`'s lane→bit order is
  endianness-dependent; on big-endian it is reversed, so the rewrite is
  suppressed (`DL->isBigEndian()`).
* **Cost-model gated.** Only fires when the `bitcast` (plus optional `zext`) is
  cheaper than the `select`+`reduce` it replaces. On x86 the `bitcast` is a real
  movemask; on AArch64 it is the `and`+`addv` reduction — both cheaper than the
  scatter. On a target where the i1→int bitcast is more expensive, the gate
  declines and the IR is left alone.

---

## Transformation 2 — AArch64: lower the bitcast without a stack spill

AArch64 has no single movemask instruction, so `bitcast <N x i1> to iN` lowers
to a mask-and + horizontal-add reduction. For masks that fit in 128 bits this
is register-only and cheap. For a mask legalized from a **>128-bit** source
(e.g. `<8 x i32>`), the old code took a wrong turn.

### The bug: an orphaned stack slot → dead frame

```llvm
define i8 @movemask_from_v8i32(<8 x i32> %v) {
  %c = icmp ne <8 x i32> %v, zeroinitializer   ; <8 x i1> mask from a 256-bit vector (illegal type)
  %b = bitcast <8 x i1> %c to i8               ; pack 8 lanes -> i8
  ret i8 %b
}
```

Legalizing the `bitcast` of the illegal `<8 x i1>` took the generic
"bitcast through memory" path:

```
t20: store  <8 x i1> mask into %stack.0     ; (1) spill the mask to a fresh stack slot
t21: load   i8       from  %stack.0         ; (2) reload it as the scalar
```

A later DAGCombine recognized the round-trip and replaced it with the
register-only sequence (`uzp1`/`bic`/`addv`), **deleting the load and stores**.
But the stack *slot* `%stack.0` was never reclaimed from `MachineFrameInfo`, so
PrologEpilogInserter reserved a frame for it:

```asm
movemask_from_v8i32:
    sub  sp, sp, #16        ; <-- DEAD: reserves a frame for the orphaned %stack.0
    cmeq v1.4s, v1.4s, #0   ; the real, register-only movemask...
    cmeq v0.4s, v0.4s, #0
    uzp1 v0.8h, v0.8h, v1.8h
    ...
    add  sp, sp, #16        ; <-- DEAD: nothing in between ever touched [sp]
    ret
```

Nothing between the `sub`/`add sp` references `sp` or memory — the frame is dead
(allocated, never used). It appears only for masks legalized from >128-bit
sources; 128-bit masks already had a register-only lowering.

### The fix: narrow the lane width instead of spilling

`vectorToScalarBitmask()` previously bailed for >128-bit vectors. The scalar
`bitcast` path has no later split/concat to pick the work up, so instead of
bailing we **narrow the per-lane integer width** so the whole vector fits in
128 bits and the existing register-only path applies. The lane *count* — and so
the bitmask — is unchanged, and the weights `1<<i` still fit (at most 16 lanes
here ⇒ ≥ 8-bit lanes).

```
<8 x i1> from <8 x i32>   (256-bit, illegal)
  --> treat the mask as <8 x i16>   (128-bit: 8 lanes * 16 bits)
  --> sext to <8 x i16>, AND with <1,2,...,128>, addv  (all in registers)
```

Annotated result — no stack, no frame:

```asm
movemask_from_v8i32:
    cmeq v1.4s, v1.4s, #0     ; compare high 4 lanes (== 0)
    cmeq v0.4s, v0.4s, #0     ; compare low  4 lanes (== 0)
    uzp1 v0.8h, v0.8h, v1.8h  ; narrow 8x i32 mask -> 8x i16 (fits in 128 bits)
    ldr  q1, [x8, ...]        ; load the bit-weights <1,2,4,...,128>
    bic  v0.16b, v1.16b, v0.16b ; weights AND NOT(==0)  ==  weights where lane != 0
    addv h0, v0.8h            ; horizontal-add the disjoint bits  ==  OR  ==  the bitmask
    fmov w0, s0               ; move the i16 bitmask to a GPR
    ret
```

The store path keeps its previous split-and-concat behaviour; only the
scalar-bitcast caller passes `AllowNarrowing=true`.

### Why narrowing and not splitting

Splitting the `<N x i1>` into two `<N/2 x i1>` halves at this late point
produces messy `zip`/`shl`/`cmlt` deinterleave code (it loses the original
per-lane width and falls back to a sub-optimal `<N/2 x i16>` path), and it is a
measured regression. Narrowing the lane width reuses the existing, already-good
128-bit movemask lowering, so it is a strict improvement.

---

## End-to-end

Source → SLP → VectorCombine (T1) → AArch64 ISel (T2):

```
word |= (v[i]!=0) << i
  --SLP-->        reduce.or(shl(zext(<8 x i1>), <0..7>))
  --VectorCombine-> bitcast <8 x i1> to i8
  --AArch64 ISel--> cmeq / uzp1 / bic / addv / fmov     (register-only, no frame)
  (x86 ISel)     -> vpcmpeqb / vpmovmskb
```

## Tests

* `llvm/test/Transforms/VectorCombine/bitmask-movemask*.ll` — Transformation 1
  (forms, negatives, endianness, SLP/loop end-to-end).
* `llvm/test/CodeGen/{X86,AArch64}/bitmask-lowering-movemask.ll` — end-to-end
  IR→asm.
* `llvm/test/CodeGen/AArch64/vec-combine-compare-to-bitmask.ll`
  (`convert_large_vector`) — Transformation 2 (the no-frame wide-source case).
