#include "gpio.h"
#include "utils.h"
#include "peripherals/gpio.h"
#include "peripherals/uart.h"
#include "uart.h"

#define TXD 14
#define RXD 15


void uart_init()
{
	// Disable UART0.
    REGS_UARTPL011->cr = 0x00000000;
 
 	// Setup the GPIO pin 14 && 15.
    gpio_pin_enable(TXD);
    gpio_pin_enable(RXD);

	// Clear pending interrupts.
    REGS_UARTPL011->icr = 0x7FF;
 
	// Set integer & fractional part of baud rate.
	// Divider = UART_CLOCK/(16 * Baud)
	// Fraction part register = (Fractional part * 64) + 0.5
	// Baud = 115200.
 
	// Divider = 3000000 / (16 * 115200) = 1.627 = ~1.
    REGS_UARTPL011->ibrd = 1;

	// Fractional part register = (.627 * 64) + 0.5 = 40.6 = ~40.
    REGS_UARTPL011->fbrd = 40;
 
	// Enable FIFO & 8 bit data transmission (1 stop bit, no parity).
    REGS_UARTPL011->lcrh = (1 << 4) | (1 << 5) | (1 << 6);
 
	// Mask all interrupts.
    REGS_UARTPL011->imsc = (1 << 1) | (1 << 4) | (1 << 5) | (1 << 6) |
	                       (1 << 7) | (1 << 8) | (1 << 9) | (1 << 10);
 
	// Enable UART0, receive & transfer part of UART.
    REGS_UARTPL011->cr = (1 << 0) | (1 << 8) | (1 << 9);
}
void uart_send(char c)
{
	// Wait for UART to become ready to transmit.
	while ( REGS_UARTPL011->fr & (1 << 5) ) { }
    REGS_UARTPL011->dr = c;
}
 
char uart_recv()
{
    // Wait for UART to have received something.
    while ( REGS_UARTPL011->fr & (1 << 4) ) { }
    return REGS_UARTPL011->dr;
}
 
void uart_send_string(const char* str)
{
	for (u32 i = 0; str[i] != '\0'; i ++)
		uart_send((unsigned char)str[i]);
}
