	.att_syntax
	.file	"arrow_collect_bool.eca41ef838c30c9e-cgu.0"
	.text
	.globl	collect_bool_from_bool_vec      # -- Begin function collect_bool_from_bool_vec
	.prefalign	4, .Lfunc_end0, nop
	.type	collect_bool_from_bool_vec,@function
collect_bool_from_bool_vec:             # @collect_bool_from_bool_vec
	.cfi_startproc
# %bb.0:                                # %start
	testq	%rdx, %rdx
	je	.LBB0_3
# %bb.1:                                # %bb3.preheader
	addq	$63, %rdi
	xorl	%eax, %eax
	.p2align	4
.LBB0_2:                                # %bb3
                                        # =>This Inner Loop Header: Depth=1
	movzbl	-63(%rdi), %ecx
	movzbl	-62(%rdi), %r8d
	leaq	(%rcx,%r8,2), %rcx
	movzbl	-61(%rdi), %r8d
	leaq	(%rcx,%r8,4), %rcx
	movzbl	-60(%rdi), %r8d
	leaq	(%rcx,%r8,8), %rcx
	movzbl	-59(%rdi), %r9d
	shll	$4, %r9d
	orq	%rcx, %r9
	movzbl	-58(%rdi), %ecx
	shll	$5, %ecx
	movzbl	-57(%rdi), %r8d
	shll	$6, %r8d
	orq	%rcx, %r8
	movzbl	-56(%rdi), %ecx
	shll	$7, %ecx
	orq	%r8, %rcx
	movzbl	-55(%rdi), %r8d
	shll	$8, %r8d
	orq	%rcx, %r8
	orq	%r9, %r8
	movzbl	-54(%rdi), %ecx
	shll	$9, %ecx
	movzbl	-53(%rdi), %r9d
	shll	$10, %r9d
	orq	%rcx, %r9
	movzbl	-52(%rdi), %ecx
	shll	$11, %ecx
	orq	%r9, %rcx
	movzbl	-51(%rdi), %r9d
	shll	$12, %r9d
	orq	%rcx, %r9
	movzbl	-50(%rdi), %ecx
	shll	$13, %ecx
	orq	%r9, %rcx
	orq	%r8, %rcx
	movzbl	-49(%rdi), %r8d
	shll	$14, %r8d
	movzbl	-48(%rdi), %r9d
	shll	$15, %r9d
	orq	%r8, %r9
	movzbl	-47(%rdi), %r8d
	shll	$16, %r8d
	orq	%r9, %r8
	movzbl	-46(%rdi), %r9d
	shll	$17, %r9d
	orq	%r8, %r9
	movzbl	-45(%rdi), %r10d
	shll	$18, %r10d
	orq	%r9, %r10
	movzbl	-44(%rdi), %r8d
	shll	$19, %r8d
	orq	%r10, %r8
	orq	%rcx, %r8
	movzbl	-43(%rdi), %ecx
	shll	$20, %ecx
	movzbl	-42(%rdi), %r9d
	shll	$21, %r9d
	orq	%rcx, %r9
	movzbl	-41(%rdi), %ecx
	shll	$22, %ecx
	orq	%r9, %rcx
	movzbl	-40(%rdi), %r9d
	shll	$23, %r9d
	orq	%rcx, %r9
	movzbl	-39(%rdi), %ecx
	shll	$24, %ecx
	orq	%r9, %rcx
	movzbl	-38(%rdi), %r9d
	shlq	$25, %r9
	orq	%rcx, %r9
	movzbl	-37(%rdi), %ecx
	shlq	$26, %rcx
	orq	%r9, %rcx
	orq	%r8, %rcx
	movzbl	-36(%rdi), %r8d
	shlq	$27, %r8
	movzbl	-35(%rdi), %r9d
	shlq	$28, %r9
	orq	%r8, %r9
	movzbl	-34(%rdi), %r8d
	shlq	$29, %r8
	orq	%r9, %r8
	movzbl	-33(%rdi), %r9d
	shlq	$30, %r9
	orq	%r8, %r9
	movzbl	-32(%rdi), %r8d
	shlq	$31, %r8
	orq	%r9, %r8
	movzbl	-31(%rdi), %r9d
	shlq	$32, %r9
	orq	%r8, %r9
	movzbl	-30(%rdi), %r10d
	shlq	$33, %r10
	orq	%r9, %r10
	movzbl	-29(%rdi), %r8d
	shlq	$34, %r8
	orq	%r10, %r8
	orq	%rcx, %r8
	movzbl	-28(%rdi), %ecx
	shlq	$35, %rcx
	movzbl	-27(%rdi), %r9d
	shlq	$36, %r9
	orq	%rcx, %r9
	movzbl	-26(%rdi), %ecx
	shlq	$37, %rcx
	orq	%r9, %rcx
	movzbl	-25(%rdi), %r9d
	shlq	$38, %r9
	orq	%rcx, %r9
	movzbl	-24(%rdi), %ecx
	shlq	$39, %rcx
	orq	%r9, %rcx
	movzbl	-23(%rdi), %r9d
	shlq	$40, %r9
	orq	%rcx, %r9
	movzbl	-22(%rdi), %ecx
	shlq	$41, %rcx
	orq	%r9, %rcx
	movzbl	-21(%rdi), %r9d
	shlq	$42, %r9
	orq	%rcx, %r9
	movzbl	-20(%rdi), %ecx
	shlq	$43, %rcx
	orq	%r9, %rcx
	orq	%r8, %rcx
	movzbl	-19(%rdi), %r8d
	shlq	$44, %r8
	movzbl	-18(%rdi), %r9d
	shlq	$45, %r9
	orq	%r8, %r9
	movzbl	-17(%rdi), %r8d
	shlq	$46, %r8
	orq	%r9, %r8
	movzbl	-16(%rdi), %r9d
	shlq	$47, %r9
	orq	%r8, %r9
	movzbl	-15(%rdi), %r8d
	shlq	$48, %r8
	orq	%r9, %r8
	movzbl	-14(%rdi), %r9d
	shlq	$49, %r9
	orq	%r8, %r9
	movzbl	-13(%rdi), %r8d
	shlq	$50, %r8
	orq	%r9, %r8
	movzbl	-12(%rdi), %r9d
	shlq	$51, %r9
	orq	%r8, %r9
	movzbl	-11(%rdi), %r10d
	shlq	$52, %r10
	orq	%r9, %r10
	movzbl	-10(%rdi), %r8d
	shlq	$53, %r8
	orq	%r10, %r8
	orq	%rcx, %r8
	movzbl	-9(%rdi), %ecx
	shlq	$54, %rcx
	movzbl	-8(%rdi), %r9d
	shlq	$55, %r9
	orq	%rcx, %r9
	movzbl	-7(%rdi), %ecx
	shlq	$56, %rcx
	orq	%r9, %rcx
	movzbl	-6(%rdi), %r9d
	shlq	$57, %r9
	orq	%rcx, %r9
	movzbl	-5(%rdi), %ecx
	shlq	$58, %rcx
	orq	%r9, %rcx
	movzbl	-4(%rdi), %r9d
	shlq	$59, %r9
	orq	%rcx, %r9
	movzbl	-3(%rdi), %ecx
	shlq	$60, %rcx
	orq	%r9, %rcx
	movzbl	-2(%rdi), %r9d
	shlq	$61, %r9
	orq	%rcx, %r9
	movzbl	-1(%rdi), %ecx
	shlq	$62, %rcx
	orq	%r9, %rcx
	movzbl	(%rdi), %r9d
	shlq	$63, %r9
	orq	%rcx, %r9
	orq	%r8, %r9
	movq	%r9, (%rsi,%rax,8)
	incq	%rax
	addq	$64, %rdi
	cmpq	%rax, %rdx
	jne	.LBB0_2
.LBB0_3:                                # %bb4
	retq
.Lfunc_end0:
	.size	collect_bool_from_bool_vec, .Lfunc_end0-collect_bool_from_bool_vec
	.cfi_endproc
                                        # -- End function
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	4, 0x0                          # -- Begin function collect_bool_from_i32_gt
.LCPI1_0:
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	1                               # 0x1
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
	.byte	0                               # 0x0
.LCPI1_1:
	.quad	2                               # 0x2
	.quad	2                               # 0x2
.LCPI1_2:
	.quad	1                               # 0x1
	.quad	1                               # 0x1
.LCPI1_3:
	.quad	4                               # 0x4
	.quad	4                               # 0x4
	.text
	.globl	collect_bool_from_i32_gt
	.prefalign	4, .Lfunc_end1, nop
	.type	collect_bool_from_i32_gt,@function
collect_bool_from_i32_gt:               # @collect_bool_from_i32_gt
	.cfi_startproc
# %bb.0:                                # %start
	testq	%rdx, %rdx
	je	.LBB1_5
# %bb.1:                                # %bb3.preheader
	movd	%ecx, %xmm0
	pshufd	$0, %xmm0, %xmm0                # xmm0 = xmm0[0,0,0,0]
	addq	$8, %rdi
	xorl	%eax, %eax
	movdqa	.LCPI1_0(%rip), %xmm1           # xmm1 = [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0]
	movdqa	.LCPI1_1(%rip), %xmm2           # xmm2 = [2,2]
	movdqa	.LCPI1_2(%rip), %xmm3           # xmm3 = [1,1]
	movdqa	.LCPI1_3(%rip), %xmm4           # xmm4 = [4,4]
	.p2align	4
.LBB1_2:                                # %bb3
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_3 Depth 2
	xorpd	%xmm5, %xmm5
	xorl	%ecx, %ecx
	movdqa	%xmm1, %xmm7
	xorpd	%xmm6, %xmm6
	.p2align	4
.LBB1_3:                                # %vector.body
                                        #   Parent Loop BB1_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movdqa	%xmm7, %xmm8
	paddq	%xmm2, %xmm8
	movq	-8(%rdi,%rcx,4), %xmm9          # xmm9 = mem[0],zero
	movq	(%rdi,%rcx,4), %xmm10           # xmm10 = mem[0],zero
	pcmpgtd	%xmm0, %xmm9
	pshufd	$212, %xmm9, %xmm9              # xmm9 = xmm9[0,1,1,3]
	pand	%xmm3, %xmm9
	pcmpgtd	%xmm0, %xmm10
	pshufd	$212, %xmm10, %xmm10            # xmm10 = xmm10[0,1,1,3]
	pand	%xmm3, %xmm10
	movdqa	%xmm9, %xmm11
	psllq	%xmm7, %xmm11
	pshufd	$238, %xmm7, %xmm12             # xmm12 = xmm7[2,3,2,3]
	psllq	%xmm12, %xmm9
	movsd	%xmm11, %xmm9                   # xmm9 = xmm11[0],xmm9[1]
	orpd	%xmm9, %xmm6
	movdqa	%xmm10, %xmm9
	psllq	%xmm8, %xmm9
	pshufd	$238, %xmm8, %xmm8              # xmm8 = xmm8[2,3,2,3]
	psllq	%xmm8, %xmm10
	movsd	%xmm9, %xmm10                   # xmm10 = xmm9[0],xmm10[1]
	orpd	%xmm10, %xmm5
	addq	$4, %rcx
	paddq	%xmm4, %xmm7
	cmpq	$64, %rcx
	jne	.LBB1_3
# %bb.4:                                # %bb6
                                        #   in Loop: Header=BB1_2 Depth=1
	orpd	%xmm6, %xmm5
	pshufd	$238, %xmm5, %xmm6              # xmm6 = xmm5[2,3,2,3]
	por	%xmm5, %xmm6
	movq	%xmm6, (%rsi,%rax,8)
	incq	%rax
	addq	$256, %rdi                      # imm = 0x100
	cmpq	%rdx, %rax
	jne	.LBB1_2
.LBB1_5:                                # %bb4
	retq
.Lfunc_end1:
	.size	collect_bool_from_i32_gt, .Lfunc_end1-collect_bool_from_i32_gt
	.cfi_endproc
                                        # -- End function
	.ident	"rustc version 1.94.1 (e408947bf 2026-03-25)"
	.section	".note.GNU-stack","",@progbits
