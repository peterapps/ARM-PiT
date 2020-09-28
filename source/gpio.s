/*
Pi GPIO info:
	- GPIO controller address is 0x20200000
	- 00-24: function select
	- 28-36: turn on pin
	- 40-48: turn off pin
	- 52-60: pin input

	- First 10 pins use lowest 4 bytes, second 10 next 4 bytes, etc.
		- 54 pins total --> 6 sets of 4 bytes
		- Every 3 bits in 4 bytes correspond to pin number
*/

.globl GetGpioAddress
GetGpioAddress:
    ldr r0,=0x20200000
    mov pc, lr @ Return program counter to return address

.globl SetGpioFunction
SetGpioFunction:
    @ r0 = pin number, r1 = function
    cmp r0, #53 @ the pin number must be 0 to 53
    @ cmpls only runs if comparison was Lower or Same
    cmpls r1, #7 @ function must be 0 to 7
    @ movhi only runs if comparison was Higher
    movhi pc, lr @ if (r0 > 53 or r1 > 7) return

    push {lr} @ push return address to stack
    mov r2, r0 @ r2 = pin number
    bl GetGpioAddress @ r0 = GetGpioAddress()

functionLoop$:
    cmp r2, #9
    subhi r2, #10 @ If pin > 9, subtract 10
    addhi r0, #4 @ If pin > 9, add 4 to GPIO controller address
    bhi functionLoop$ @ Check again

    @ Now r2 is 0 to 9 (pin % 10)
    @ r0 contains address of correct 4 byte section
    @ r0 = 0x20200000 + 4*(pin / 10)

    add r2, r2, lsl #1 @ r2 *= 3 (r2 = r2 + 2*r2)
    lsl r1, r2 @ Set the pin number's bit high
    str r1, [r0]

    pop {pc} @ Return by popping return address into PC

.globl SetGpio
SetGpio:
    @ Use register aliases
    pinNum .req r0
    pinVal .req r1

    cmp pinNum, #53
    movhi pc, lr @ if pinNum > 53: return
    push {lr}

    mov r2, pinNum @ r2 = pinNum
    .unreq pinNum
    pinNum .req r2 @ Change pinNum alias to r2

    bl GetGpioAddress
    gpioAddr .req r0
    pinBank .req r3 @ There are two pin banks, for bins 0-31 and 32-53
    lsr pinBank, pinNum, #5 @ Divide pin number by 32 to find pin bank
    lsl pinBank, #2
    add gpioAddr, pinBank
    .unreq pinBank

    and pinNum, #31 @ Find pin num relative to pin bank
    setBit .req r3
    mov setBit, #1
    lsl setBit, pinNum @ set the bit corresponding to pinNum
    .unreq pinNum

    teq pinVal, #0 @ Test if pinVal == 0
    .unreq pinVal
    streq setBit, [gpioAddr, #40] @ if pinVal == 0: store at the off address
    strne setBit, [gpioAddr, #28] @ if pinVal != 0: store at the on address
    .unreq setBit
    .unreq gpioAddr
    pop {pc} @ Return
