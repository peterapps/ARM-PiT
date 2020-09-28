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

loop$:
	mov r0, #16 @ pinNum = 16
	mov r1, #1 @ pinFunc = 1 (write, I think)
	bl SetGpioFunction @ SetGpioFunction(16, 1)

	bl WaitFunc @ wait

	mov r0, #16 @ pinNum = 16
	mov r1, #0 @ pinVal = 0 (turn off pin/turn on LED)
	bl SetGpio @ SetGpio(16, 0)

	bl WaitFunc @ wait

	mov r0, #16 @ pinNum = 16
	mov r1, #1 @ pinVal = 1 (turn on pin/turn off LED)
	bl SetGpio @ SetGpio(16, 1)

	b loop$

WaitFunc:
	push {r0} @ Save r0
	mov r0, #0x3F0000 @ Initialize counter
wait$:
	sub r0, #1 @ Decrement counter
	cmp r0, #0
	bne wait$ @ if counter != 0: goto wait
	pop {r0} @ Restore r0
	mov pc, lr @ Return
