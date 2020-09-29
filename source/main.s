/*
ARM11 info:
	- General purpose registers r0 through r12
	- ldr reg,=val and mov reg,#val both set reg to val
		- mov is faster but can only be used for some values

Pi GPIO info:
	- OK LED is GPIO pin 16
		- Second set of 4 bytes for pins 10-19
		- 6th set of 3 bits, so 18th bit
		- The LED is active low, so turn the pin off
 */

.section .init	@ Makefile uses .init as start of output
.globl _start	@ Puts _start in the ELF file
_start:
	b main

.section .text
main:
	mov sp, #0x8000 @ Initialize stack at 0x8000

	mov r0, #16 @ pinNum = 16
	mov r1, #1 @ pinFunc = 1 (write, I think)
	bl SetGpioFunction @ SetGpioFunction(16, 1)

	ldr r4,=pattern @ Load address of pattern
	ldr r4, [r4] @ Load pattern from memory
	mov r5, #0 @ r5 is sequence position

loop$:
	mov r0, #16 @ pinNum = 16
	mov r1, #1 @ pinVal
	lsl r1, r5 @ Shift to sequence position
	and r1, r4 @ will be 0 if pattern[seq] is 0, else non-zero
	bl SetGpio @ SetGpio(16, pinVal)

	mov r0, #0x3F0000
	bl TimerWait

	b loop$

.section .data
@ .align N aligns data to a multiple of 2^N
@ .int copies the constant into the output
.align 2
pattern:
	.int 0b11111111101010100010001000101010
