/*
ARM11 info:
	- General purpose registers r0 through r12
	- ldr reg,=val and mov reg,#val both set reg to val
		- mov is faster but can only be used for some values

Pi GPIO info:
	- GPIO controller address is 0x20200000
	- 00-24: function select
	- 28-36: turn on pin
	- 40-48: turn off pin
	- 52-60: pin input

	- First 10 pins use lowest 4 bytes, second 10 next 4 bytes, etc.
		- 54 pins total --> 6 sets of 4 bytes
		- Every 3 bits in 4 bytes correspond to pin number
	- OK LED is GPIO pin 16
		- Second set of 4 bytes for pins 10-19
		- 6th set of 3 bits, so 18th bit
		- The LED is active low, so turn the pin off
 */

.section .init	@ Makefile uses .init as start of output
.globl _start	@ Puts _start in the ELF file
_start:

	ldr r0, =0x20200000 @ GPIO controller address
	mov r1, #1
	lsl r1, #18 @ r1 = 2^18
	str r1, [r0, #4] @ Second set of 4 bytes

	lsr r1, #2 @ r1 = 2^16 (for the 16th bit)

	str r1, [r0, #40] @ Turn off (byte 40) pin 16

	mov r2, #0x3F0000 @ Use r2 as counter
wait1$:
	sub r2, #1 @ Decrement counter
	cmp r2, #0
	bne wait1$ @ if (r2 != 0) goto wait1

	str r1, [r0, #28] @ Turn on (byte 40) pin 16

	mov r2, #0x3F0000
wait2$:
	sub r2, #1 @ Decrement counter
	cmp r2, #0 @ Compare to zero
	bne wait2$ @ if (r2 != 0) goto wait2

	@ That was the tutorial way.
	@ Now I will try doing it with a toggle, r5
	add r3, r0, #40 @ r3 = off address
	add r4, r0, #28 @ r4 = on address
	mov r5, r4 @ It was just set to on
loop$:
	cmp r5, r3
	bne toggleOn$ @ if (r5 == off) goto toggleOn
	mov r5, r3 @ r5 = off
	b set$
toggleOn$:
	mov r5, r4 @ r5 = on
set$:
	str r1, [r5, #0] @ Store 2^16 at on/off address
	mov r2, #0x3F0000 @ Initialize counter
wait$:
	sub r2, #1 @ Decrement counter
	cmp r2, #0
	bne wait$ @ if (r2 != 0) goto wait
	b loop$ @ loop again
