#ifndef _ASM_X86_FUTEX_H
#define _ASM_X86_FUTEX_H

#ifdef __KERNEL__

#include <arch/uaccess.h>
#include <arch/asm.h>
#include <arch/errno.h>
#include <arch/processor.h>
#include <arch/system.h>


#define __futex_atomic_op(insn, ret, oldval, uaddr, tmp, oparg)		\
do {									\
	/* uaccess_enable(); */						\
	asm volatile(							\
"	prfm	pstl1strm, %2\n"					\
"1:	ldxr	%w1, %2\n"						\
	insn "\n"							\
"2:	stlxr	%w3, %w0, %2\n"						\
"	cbnz	%w3, 1b\n"						\
"	dmb	ish\n"							\
"3:\n"									\
"	.pushsection .fixup,\"ax\"\n"					\
"	.align	2\n"							\
"4:	mov	%w0, %w5\n"						\
"	b	3b\n"							\
"	.popsection\n"							\
	_ASM_EXTABLE(1b, 4b)						\
	_ASM_EXTABLE(2b, 4b)						\
	: "=&r" (ret), "=&r" (oldval), "+Q" (*uaddr), "=&r" (tmp)	\
	: "r" (oparg), "Ir" (-EFAULT)					\
	: "memory");							\
	/* uaccess_disable(); */						\
} while (0)

static inline int
futex_atomic_op_inuser (int encoded_op, u32 __user *uaddr)
{
	int op = (encoded_op >> 28) & 7;
	int cmp = (encoded_op >> 24) & 15;
	int oparg = (encoded_op << 8) >> 20;
	int cmparg = (encoded_op << 20) >> 20;
	int oldval = 0, ret, tmp;

	if (encoded_op & (FUTEX_OP_OPARG_SHIFT << 28))
		oparg = 1 << oparg;

	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
		return -EFAULT;

	/* pagefault_disable(); */

	switch (op) {
	case FUTEX_OP_SET:
		__futex_atomic_op("mov	%w0, %w4",
				  ret, oldval, uaddr, tmp, oparg);
		break;
	case FUTEX_OP_ADD:
		__futex_atomic_op("add	%w0, %w1, %w4",
				  ret, oldval, uaddr, tmp, oparg);
		break;
	case FUTEX_OP_OR:
		__futex_atomic_op("orr	%w0, %w1, %w4",
				  ret, oldval, uaddr, tmp, oparg);
		break;
	case FUTEX_OP_ANDN:
		__futex_atomic_op("and	%w0, %w1, %w4",
				  ret, oldval, uaddr, tmp, ~oparg);
		break;
	case FUTEX_OP_XOR:
		__futex_atomic_op("eor	%w0, %w1, %w4",
				  ret, oldval, uaddr, tmp, oparg);
		break;
	default:
		ret = -ENOSYS;
	}

	/* pagefault_enable(); */

	if (!ret) {
		switch (cmp) {
		case FUTEX_OP_CMP_EQ: ret = (oldval == cmparg); break;
		case FUTEX_OP_CMP_NE: ret = (oldval != cmparg); break;
		case FUTEX_OP_CMP_LT: ret = (oldval < cmparg); break;
		case FUTEX_OP_CMP_GE: ret = (oldval >= cmparg); break;
		case FUTEX_OP_CMP_LE: ret = (oldval <= cmparg); break;
		case FUTEX_OP_CMP_GT: ret = (oldval > cmparg); break;
		default: ret = -ENOSYS;
		}
	}
	return ret;
}

static inline int
futex_atomic_cmpxchg_inatomic(u32 *uval, u32 __user *uaddr,
			      u32 oldval, u32 newval)
{
	int ret = 0;
	u32 val, tmp;

	if (!access_ok(VERIFY_WRITE, uaddr, sizeof(u32)))
		return -EFAULT;

	/* uaccess_enable(); */
	asm volatile("// futex_atomic_cmpxchg_inatomic\n"
"	prfm	pstl1strm, %2\n"
"1:	ldxr	%w1, %2\n"
"	sub	%w3, %w1, %w4\n"
"	cbnz	%w3, 3f\n"
"2:	stlxr	%w3, %w5, %2\n"
"	cbnz	%w3, 1b\n"
"	dmb	ish\n"
"3:\n"
"	.pushsection .fixup,\"ax\"\n"
"4:	mov	%w0, %w6\n"
"	b	3b\n"
"	.popsection\n"
	_ASM_EXTABLE(1b, 4b)
	_ASM_EXTABLE(2b, 4b)
	: "+r" (ret), "=&r" (val), "+Q" (*uaddr), "=&r" (tmp)
	: "r" (oldval), "r" (newval), "Ir" (-EFAULT)
	: "memory");

	/* uaccess_disable(); */

	*uval = val;
	return ret;
}


#endif
#endif
