#include "common.h"
#include "uart.h"
#include "printf.h"
#include "utils.h"

void putc(void *p, char c) {
    if (c == '\n') {
        uart_send('\r');
    }

    uart_send(c);
}

#if RPI_VERSION == 3 || RPI_VERSION == 4
// arguments for AArch64
void kernel_main(u64 dtb_ptr32, u64 x1, u64 x2, u64 x3)
#else
// arguments for AArch32 - Pi Zero
void kernel_main(u32 r0, u32 r1, u32 atags)
#endif
{
	// initialize UART for Raspi0
	uart_init();
    init_printf(0, putc);

    printf("\nRasperry PI Bare Metal OS Initializing...\n");
    printf("r0:%x\t",r0);
    printf("r1:%x\t",r1);
    printf("atags:%x\n",atags);

    printf("\nException Level: %d\n", get_el());

 	while (1)
		uart_send(uart_recv());
}
