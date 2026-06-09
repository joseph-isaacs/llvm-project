	.att_syntax
	.file	"chain64.ll"
	.text
	.globl	chain64_i32_sgt                 # -- Begin function chain64_i32_sgt
	.prefalign	4, .Lfunc_end0, nop
	.type	chain64_i32_sgt,@function
chain64_i32_sgt:                        # @chain64_i32_sgt
# %bb.0:                                # %entry
	vmovdqu	128(%rdi), %ymm0
	vmovdqu	160(%rdi), %ymm1
	vmovdqu	192(%rdi), %ymm2
	vmovdqu	224(%rdi), %ymm3
	vmovdqu	(%rdi), %ymm4
	vmovdqu	32(%rdi), %ymm5
	vmovdqu	64(%rdi), %ymm6
	vmovdqu	96(%rdi), %ymm7
	vmovd	%esi, %xmm8
	vpbroadcastd	%xmm8, %ymm8
	vpcmpgtd	%ymm8, %ymm7, %ymm7
	vpcmpgtd	%ymm8, %ymm6, %ymm6
	vpackssdw	%ymm7, %ymm6, %ymm6
	vpermq	$216, %ymm6, %ymm6              # ymm6 = ymm6[0,2,1,3]
	vpcmpgtd	%ymm8, %ymm5, %ymm5
	vpcmpgtd	%ymm8, %ymm4, %ymm4
	vpackssdw	%ymm5, %ymm4, %ymm4
	vpermq	$216, %ymm4, %ymm4              # ymm4 = ymm4[0,2,1,3]
	vpacksswb	%ymm6, %ymm4, %ymm4
	vpermq	$216, %ymm4, %ymm4              # ymm4 = ymm4[0,2,1,3]
	vpmovmskb	%ymm4, %ecx
	vpcmpgtd	%ymm8, %ymm3, %ymm3
	vpcmpgtd	%ymm8, %ymm2, %ymm2
	vpackssdw	%ymm3, %ymm2, %ymm2
	vpermq	$216, %ymm2, %ymm2              # ymm2 = ymm2[0,2,1,3]
	vpcmpgtd	%ymm8, %ymm1, %ymm1
	vpcmpgtd	%ymm8, %ymm0, %ymm0
	vpackssdw	%ymm1, %ymm0, %ymm0
	vpermq	$216, %ymm0, %ymm0              # ymm0 = ymm0[0,2,1,3]
	vpacksswb	%ymm2, %ymm0, %ymm0
	vpermq	$216, %ymm0, %ymm0              # ymm0 = ymm0[0,2,1,3]
	vpmovmskb	%ymm0, %eax
	shlq	$32, %rax
	orq	%rcx, %rax
	vzeroupper
	retq
.Lfunc_end0:
	.size	chain64_i32_sgt, .Lfunc_end0-chain64_i32_sgt
                                        # -- End function
	.globl	chain64_bool                    # -- Begin function chain64_bool
	.prefalign	4, .Lfunc_end1, nop
	.type	chain64_bool,@function
chain64_bool:                           # @chain64_bool
# %bb.0:                                # %entry
	vpxor	%xmm0, %xmm0, %xmm0
	vpcmpeqb	(%rdi), %ymm0, %ymm1
	vpmovmskb	%ymm1, %ecx
	vpcmpeqb	32(%rdi), %ymm0, %ymm0
	vpmovmskb	%ymm0, %eax
	shlq	$32, %rax
	orq	%rcx, %rax
	notq	%rax
	vzeroupper
	retq
.Lfunc_end1:
	.size	chain64_bool, .Lfunc_end1-chain64_bool
                                        # -- End function
	.globl	chain8_i32_sgt                  # -- Begin function chain8_i32_sgt
	.prefalign	4, .Lfunc_end2, nop
	.type	chain8_i32_sgt,@function
chain8_i32_sgt:                         # @chain8_i32_sgt
# %bb.0:                                # %entry
	vmovdqu	(%rdi), %ymm0
	vmovd	%esi, %xmm1
	vpbroadcastd	%xmm1, %ymm1
	vpcmpgtd	%ymm1, %ymm0, %ymm0
	vmovmskps	%ymm0, %eax
	vzeroupper
	retq
.Lfunc_end2:
	.size	chain8_i32_sgt, .Lfunc_end2-chain8_i32_sgt
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
