#define ENDPROC(name) \
	.type name, %function; \
	END(name)
#define ENTRY(name) \
	.globl name; \
	name:
#define END(name) \
	.size name, .-name

.globl delay
delay:
#if RPI_VERSION == 0 // Pi Zero/1 AArch 32
    sub r0, r0, #1
    bne delay
    bx lr
#else
    subs x0, x0, #1
    bne delay
    ret
#endif

.globl put32
put32:
#if RPI_VERSION == 0 // Pi Zero/1 AArch 32
    str r1, [r0]
    bx lr
#else
    str w1, [x0]
    ret
#endif

.globl get32
get32:
#if RPI_VERSION == 0 // Pi Zero/1 AArch 32
    ldr r0, [r0]
    bx lr
#else
    ldr w0, [x0]
    ret
#endif

.globl get_el
get_el:
#if RPI_VERSION == 0 // Pi Zero/1 AArch 32
	mrs r0, CPSR
    and r0, r0, #0x0F	;@ mask for lower 4 bits of register for  Mode bits [3:0] PSR
    bx lr
#else
    mrs x0, CurrentEL
    lsr x0, x0, #2
    ret
#endif


#if RPI_VERSION == 0 // Pi Zero/1 AArch 32

.macro ARM_DIV_BODY dividend, divisor, result, curbit
	@ Initially shift the divisor left 3 bits if possible,
	@ set curbit accordingly.  This allows for curbit to be located
	@ at the left end of each 4 bit nibbles in the division loop
	@ to save one loop in most cases.
	tst	\divisor, #0xe0000000
	moveq	\divisor, \divisor, lsl #3
	moveq	\curbit, #8
	movne	\curbit, #1
	@ Unless the divisor is very big, shift it up in multiples of
	@ four bits, since this is the amount of unwinding in the main
	@ division loop.  Continue shifting until the divisor is
	@ larger than the dividend.
1:	cmp	\divisor, #0x10000000
	cmplo	\divisor, \dividend
	movlo	\divisor, \divisor, lsl #4
	movlo	\curbit, \curbit, lsl #4
	blo	1b
	@ For very big divisors, we must shift it a bit at a time, or
	@ we will be in danger of overflowing.
1:	cmp	\divisor, #0x80000000
	cmplo	\divisor, \dividend
	movlo	\divisor, \divisor, lsl #1
	movlo	\curbit, \curbit, lsl #1
	blo	1b
	mov	\result, #0

	@ Division loop
1:	cmp	\dividend, \divisor
	subhs	\dividend, \dividend, \divisor
	orrhs	\result,   \result,   \curbit
	cmp	\dividend, \divisor,  lsr #1
	subhs	\dividend, \dividend, \divisor, lsr #1
	orrhs	\result,   \result,   \curbit,  lsr #1
	cmp	\dividend, \divisor,  lsr #2
	subhs	\dividend, \dividend, \divisor, lsr #2
	orrhs	\result,   \result,   \curbit,  lsr #2
	cmp	\dividend, \divisor,  lsr #3
	subhs	\dividend, \dividend, \divisor, lsr #3
	orrhs	\result,   \result,   \curbit,  lsr #3
	cmp	\dividend, #0			@ Early termination?
	movnes	\curbit,   \curbit,  lsr #4	@ No, any more bits to do?
	movne	\divisor,  \divisor, lsr #4
	bne	1b
.endm

.macro ARM_DIV2_ORDER divisor, order
	cmp	\divisor, #(1 << 16)
	movhs	\divisor, \divisor, lsr #16
	movhs	\order, #16
	movlo	\order, #0
	cmp	\divisor, #(1 << 8)
	movhs	\divisor, \divisor, lsr #8
	addhs	\order, \order, #8
	cmp	\divisor, #(1 << 4)
	movhs	\divisor, \divisor, lsr #4
	addhs	\order, \order, #4
	cmp	\divisor, #(1 << 2)
	addhi	\order, \order, #3
	addls	\order, \order, \divisor, lsr #1
.endm

ENTRY(__div0)
    bl __div0   @ Handle divide by zero by hanging
ENDPROC(__div0)

ENTRY(__aeabi_uidiv)
	subs	r2, r1, #1
	moveq	pc, lr
	bcc	Ldiv0
	cmp	r0, r1
	bls	11f
	tst	r1, r2
	beq	12f
	ARM_DIV_BODY r0, r1, r2, r3
	mov	r0, r2
	mov	pc, lr
11:	moveq	r0, #1
	movne	r0, #0
	mov	pc, lr
12:	ARM_DIV2_ORDER r1, r2
	mov	r0, r0, lsr r2
	mov	pc, lr
ENDPROC(__aeabi_uidiv)

ENTRY(__aeabi_uidivmod)
	stmfd	sp!, {r0, r1, ip, lr}
	bl	__aeabi_uidiv
	ldmfd	sp!, {r1, r2, ip, lr}
	mul	r3, r0, r2
	sub	r1, r1, r3
	mov	pc, lr
ENDPROC(__aeabi_uidivmod)

Ldiv0:
	str	lr, [sp, #-8]!
	bl	__div0          
	mov	r0, #0			@ About as wrong as it could be.
	ldr	pc, [sp], #8
ENDPROC(Ldiv0)

#endif