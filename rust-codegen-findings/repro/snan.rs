use std::hint::black_box as bb;
fn main() {
    let snan = f32::from_bits(0x7f80_0001); // signalling NaN
    let qnan = f32::NAN;
    println!("max(sNaN,1)={:?} max(1,sNaN)={:?} min(sNaN,1)={:?} max(qNaN,1)={:?} clamp(sNaN,0,5)={:?} fold_max=[{:?}]",
        bb(snan).max(bb(1.0)), bb(1.0f32).max(bb(snan)), bb(snan).min(bb(1.0)), bb(qnan).max(bb(1.0)),
        bb(snan).max(bb(0.0)).min(bb(5.0)), bb([snan, 2.0, 1.0]).iter().copied().fold(f32::MIN, f32::max));
}
