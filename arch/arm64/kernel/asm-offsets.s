	.arch armv8.3-a+crc
	.file	"asm-offsets.c"
// GNU C99 (Ubuntu 13.3.0-6ubuntu2~24.04) version 13.3.0 (aarch64-linux-gnu)
//	compiled by GNU C version 13.3.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.26-GMP

// GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
// options passed: -march=armv8.3-a -mlittle-endian -mabi=lp64 -g -g -O2 -std=gnu99 -fno-strict-aliasing -fno-strict-overflow -fno-common -fno-pie -fno-stack-protector -fgnu89-inline -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-builtin -ffunction-sections -fno-reorder-blocks -funit-at-a-time -fasynchronous-unwind-tables -fstack-clash-protection
	.text
.Ltext0:
	.file 0 "/home/prof/kitten" "arch/arm64/kernel/asm-offsets.c"
	.section	.text.startup.main,"ax",@progbits
	.align	2
	.p2align 4,,11
	.global	main
	.type	main, %function
main:
.LFB225:
	.file 1 "arch/arm64/kernel/asm-offsets.c"
	.loc 1 41 1 view -0
	.cfi_startproc
	.loc 1 43 3 view .LVU1
#APP
// 43 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 45 3 view .LVU2
// 45 "arch/arm64/kernel/asm-offsets.c" 1
	
->TI_FLAGS 192 offsetof(struct task_struct, arch.flags)	//
// 0 "" 2
	.loc 1 53 3 view .LVU3
// 53 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 58 3 view .LVU4
// 58 "arch/arm64/kernel/asm-offsets.c" 1
	
->TSK_ARCH_THREAD_CPU_CONTEXT_SP 296 offsetof(struct task_struct, arch) + offsetof(struct arch_task, thread) + offsetof(struct thread_struct, cpu_context) + offsetof(struct cpu_context, sp)	//
// 0 "" 2
	.loc 1 59 3 view .LVU5
// 59 "arch/arm64/kernel/asm-offsets.c" 1
	
->TSK_ARCH_THREAD_CPU_CONTEXT_USERSP 320 offsetof(struct task_struct, arch) + offsetof(struct arch_task, thread) + offsetof(struct thread_struct, cpu_context) + offsetof(struct cpu_context, usersp)	//
// 0 "" 2
	.loc 1 63 3 view .LVU6
// 63 "arch/arm64/kernel/asm-offsets.c" 1
	
->TSK_ARCH_FLAGS 192 offsetof(struct task_struct, arch) + offsetof(struct arch_task, flags)	//
// 0 "" 2
	.loc 1 66 3 view .LVU7
// 66 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 67 3 view .LVU8
// 67 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_X0 0 offsetof(struct pt_regs, regs[0])	//
// 0 "" 2
	.loc 1 68 3 view .LVU9
// 68 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_X1 8 offsetof(struct pt_regs, regs[1])	//
// 0 "" 2
	.loc 1 69 3 view .LVU10
// 69 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_X2 16 offsetof(struct pt_regs, regs[2])	//
// 0 "" 2
	.loc 1 70 3 view .LVU11
// 70 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_X3 24 offsetof(struct pt_regs, regs[3])	//
// 0 "" 2
	.loc 1 71 3 view .LVU12
// 71 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_X4 32 offsetof(struct pt_regs, regs[4])	//
// 0 "" 2
	.loc 1 72 3 view .LVU13
// 72 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_X5 40 offsetof(struct pt_regs, regs[5])	//
// 0 "" 2
	.loc 1 73 3 view .LVU14
// 73 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_X6 48 offsetof(struct pt_regs, regs[6])	//
// 0 "" 2
	.loc 1 74 3 view .LVU15
// 74 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_X7 56 offsetof(struct pt_regs, regs[7])	//
// 0 "" 2
	.loc 1 75 3 view .LVU16
// 75 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_LR 240 offsetof(struct pt_regs, regs[30])	//
// 0 "" 2
	.loc 1 76 3 view .LVU17
// 76 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_SP 248 offsetof(struct pt_regs, sp)	//
// 0 "" 2
	.loc 1 80 3 view .LVU18
// 80 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_PSTATE 264 offsetof(struct pt_regs, pstate)	//
// 0 "" 2
	.loc 1 81 3 view .LVU19
// 81 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_PC 256 offsetof(struct pt_regs, pc)	//
// 0 "" 2
	.loc 1 82 3 view .LVU20
// 82 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_ORIG_X0 272 offsetof(struct pt_regs, orig_x0)	//
// 0 "" 2
	.loc 1 83 3 view .LVU21
// 83 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_SYSCALLNO 280 offsetof(struct pt_regs, syscallno)	//
// 0 "" 2
	.loc 1 84 3 view .LVU22
// 84 "arch/arm64/kernel/asm-offsets.c" 1
	
->S_FRAME_SIZE 288 sizeof(struct pt_regs)	//
// 0 "" 2
	.loc 1 85 3 view .LVU23
// 85 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 87 3 view .LVU24
// 87 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 90 3 view .LVU25
// 90 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 92 3 view .LVU26
// 92 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 93 3 view .LVU27
// 93 "arch/arm64/kernel/asm-offsets.c" 1
	
->PAGE_SZ 4096 PAGE_SIZE	//
// 0 "" 2
	.loc 1 94 3 view .LVU28
// 94 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 99 3 view .LVU29
// 99 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 105 3 view .LVU30
// 105 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 114 3 view .LVU31
// 114 "arch/arm64/kernel/asm-offsets.c" 1
	
->NSEC_PER_SEC 1000000000 NSEC_PER_SEC	//
// 0 "" 2
	.loc 1 115 3 view .LVU32
// 115 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 131 3 view .LVU33
// 131 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 132 3 view .LVU34
// 132 "arch/arm64/kernel/asm-offsets.c" 1
	
->TVAL_TV_SEC 0 offsetof(struct timeval, tv_sec)	//
// 0 "" 2
	.loc 1 133 3 view .LVU35
// 133 "arch/arm64/kernel/asm-offsets.c" 1
	
->TVAL_TV_USEC 8 offsetof(struct timeval, tv_usec)	//
// 0 "" 2
	.loc 1 134 3 view .LVU36
// 134 "arch/arm64/kernel/asm-offsets.c" 1
	
->TSPEC_TV_SEC 0 offsetof(struct timespec, tv_sec)	//
// 0 "" 2
	.loc 1 135 3 view .LVU37
// 135 "arch/arm64/kernel/asm-offsets.c" 1
	
->TSPEC_TV_NSEC 8 offsetof(struct timespec, tv_nsec)	//
// 0 "" 2
	.loc 1 136 3 view .LVU38
// 136 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 137 3 view .LVU39
// 137 "arch/arm64/kernel/asm-offsets.c" 1
	
->TZ_MINWEST 0 offsetof(struct timezone, tz_minuteswest)	//
// 0 "" 2
	.loc 1 138 3 view .LVU40
// 138 "arch/arm64/kernel/asm-offsets.c" 1
	
->TZ_DSTTIME 4 offsetof(struct timezone, tz_dsttime)	//
// 0 "" 2
	.loc 1 139 3 view .LVU41
// 139 "arch/arm64/kernel/asm-offsets.c" 1
	
->	
// 0 "" 2
	.loc 1 173 3 view .LVU42
// 173 "arch/arm64/kernel/asm-offsets.c" 1
	
->ARM_SMCCC_RES_X0_OFFS 0 offsetof(struct arm_smccc_res, a0)	//
// 0 "" 2
	.loc 1 174 3 view .LVU43
// 174 "arch/arm64/kernel/asm-offsets.c" 1
	
->ARM_SMCCC_RES_X2_OFFS 16 offsetof(struct arm_smccc_res, a2)	//
// 0 "" 2
	.loc 1 175 3 view .LVU44
// 175 "arch/arm64/kernel/asm-offsets.c" 1
	
->ARM_SMCCC_QUIRK_ID_OFFS 0 offsetof(struct arm_smccc_quirk, id)	//
// 0 "" 2
	.loc 1 176 3 view .LVU45
// 176 "arch/arm64/kernel/asm-offsets.c" 1
	
->ARM_SMCCC_QUIRK_STATE_OFFS 8 offsetof(struct arm_smccc_quirk, state)	//
// 0 "" 2
	.loc 1 178 3 view .LVU46
// 178 "arch/arm64/kernel/asm-offsets.c" 1
	
->__NR_syscall_max 534 sizeof(syscalls) - 1	//
// 0 "" 2
	.loc 1 179 3 view .LVU47
// arch/arm64/kernel/asm-offsets.c:180: }
	.loc 1 180 1 is_stmt 0 view .LVU48
#NO_APP
	mov	w0, 0	//,
	ret	
	.cfi_endproc
.LFE225:
	.size	main, .-main
	.text
.Letext0:
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.4byte	0x2d6
	.2byte	0x5
	.byte	0x1
	.byte	0x8
	.4byte	.Ldebug_abbrev0
	.uleb128 0x2
	.4byte	.LASF14
	.byte	0xc
	.4byte	.LASF0
	.4byte	.LASF1
	.4byte	.LLRL0
	.8byte	0
	.4byte	.Ldebug_line0
	.uleb128 0x1
	.byte	0x8
	.byte	0x7
	.4byte	.LASF2
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x1
	.byte	0x4
	.byte	0x7
	.4byte	.LASF3
	.uleb128 0x1
	.byte	0x8
	.byte	0x5
	.4byte	.LASF4
	.uleb128 0x1
	.byte	0x1
	.byte	0x8
	.4byte	.LASF5
	.uleb128 0x1
	.byte	0x8
	.byte	0x5
	.4byte	.LASF6
	.uleb128 0x1
	.byte	0x2
	.byte	0x7
	.4byte	.LASF7
	.uleb128 0x1
	.byte	0x1
	.byte	0x6
	.4byte	.LASF8
	.uleb128 0x1
	.byte	0x1
	.byte	0x8
	.4byte	.LASF9
	.uleb128 0x1
	.byte	0x2
	.byte	0x5
	.4byte	.LASF10
	.uleb128 0x1
	.byte	0x8
	.byte	0x7
	.4byte	.LASF11
	.uleb128 0x1
	.byte	0x1
	.byte	0x2
	.4byte	.LASF12
	.uleb128 0x1
	.byte	0x10
	.byte	0x7
	.4byte	.LASF13
	.uleb128 0x4
	.4byte	0x46
	.4byte	0x96
	.uleb128 0x5
	.4byte	0x2a
	.2byte	0x216
	.byte	0
	.uleb128 0x6
	.4byte	.LASF15
	.byte	0x1
	.byte	0x24
	.byte	0xd
	.4byte	0x85
	.2byte	0x217
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.byte	0x1
	.uleb128 0x7
	.4byte	.LASF16
	.byte	0x1
	.byte	0x28
	.byte	0x5
	.4byte	0x31
	.8byte	.LFB225
	.8byte	.LFE225-.LFB225
	.uleb128 0x1
	.byte	0x9c
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x1f
	.uleb128 0x1b
	.uleb128 0x1f
	.uleb128 0x55
	.uleb128 0x17
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0x5
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1c
	.uleb128 0x3
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x7a
	.uleb128 0x19
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.4byte	0x2c
	.2byte	0x2
	.4byte	.Ldebug_info0
	.byte	0x8
	.byte	0
	.2byte	0
	.2byte	0
	.8byte	.LFB225
	.8byte	.LFE225-.LFB225
	.8byte	0
	.8byte	0
	.section	.debug_rnglists,"",@progbits
.Ldebug_ranges0:
	.4byte	.Ldebug_ranges3-.Ldebug_ranges2
.Ldebug_ranges2:
	.2byte	0x5
	.byte	0x8
	.byte	0
	.4byte	0
.LLRL0:
	.byte	0x7
	.8byte	.LFB225
	.uleb128 .LFE225-.LFB225
	.byte	0
.Ldebug_ranges3:
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF6:
	.string	"long long int"
.LASF3:
	.string	"unsigned int"
.LASF16:
	.string	"main"
.LASF13:
	.string	"__int128 unsigned"
.LASF2:
	.string	"long unsigned int"
.LASF11:
	.string	"long long unsigned int"
.LASF15:
	.string	"syscalls"
.LASF9:
	.string	"unsigned char"
.LASF5:
	.string	"char"
.LASF4:
	.string	"long int"
.LASF12:
	.string	"_Bool"
.LASF7:
	.string	"short unsigned int"
.LASF8:
	.string	"signed char"
.LASF10:
	.string	"short int"
.LASF14:
	.ascii	"GNU C99 13.3.0 -march=armv8.3-a -mlittle-endian -mabi=lp64 -"
	.ascii	"g -g -O2 -std=gnu99 -fno-strict-aliasi"
	.string	"ng -fno-strict-overflow -fno-common -fno-pie -fno-stack-protector -fgnu89-inline -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-builtin -ffunction-sections -fno-reorder-blocks -funit-at-a-time -fasynchronous-unwind-tables -fstack-clash-protection"
	.section	.debug_line_str,"MS",@progbits,1
.LASF1:
	.string	"/home/prof/kitten"
.LASF0:
	.string	"arch/arm64/kernel/asm-offsets.c"
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",@progbits
