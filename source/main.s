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

	mov r0,#1024
	mov r1,#768
	mov r2,#16
	bl InitFrameBuffer @ Initialize frame buffer through GPU

	teq r0, #0
	bne noError$ @ if frame buffer returned successfully, goto noError

	mov r0, #16
	mov r1, #1
	bl SetGpioFunction
	mov r0, #16
	mov r1, #0
	bl SetGpio @ Turn on LED if there was an error
error$:
	b error$

noError$:
	mov r4, r0 @ r4 = fbInfoAddr

render$:
	@ r0 = color
	ldr r3, [r0, #32] @ r3 = fbAddr
	mov r1, #768 @ r1 = y = 768
	drawRow$:
		mov r2, #1024 @ r2 = x = 1024
		drawPixel$:
			strh r0, [r3] @ Store 16 bits of color at fbAddr
			add r3, r3, #2 @ Increment fbAddr
			sub r2, r2, #1 @ Decrement x
			teq r2, #0
			bne drawPixel$ @ Loop when x == 0
		
		sub r1, r1, #1 @ Decrement y
		add r0, r0, #1 @ Increment color
		teq r2, #0
		bne drawRow$ @ Loop when y == 0
	
	b render$
