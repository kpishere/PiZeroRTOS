.globl memzero
memzero:
#if RPI_VERSION == 0 // Pi Zero/1 AArch 32
    ldr r2, =0x00
memzero_loop:
    str r2, [r0, r1]!
    bne memzero_loop
    bx lr
#else 
    str xzr, [x0], #8
    subs x1, x1, #8
    b.gt memzero
    ret
#endif