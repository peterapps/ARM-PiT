/*
Pi timer info:
    - 
*/

.globl GetSystemTimerBase
GetSystemTimerBase:
    ldr r0,=0x20003000
    mov pc,lr

.globl GetTimeStamp
GetTimeStamp:
    push {lr}
    bl GetSystemTimerBase
    ldrd r0, r1, [r0, #4] @ Load 8 bytes into two separate registers
    pop {pc}

.globl TimerWait
TimerWait:
    push {lr}
    mov r3, r0 @ Target wait duration
    bl GetTimeStamp
    mov r4, r0 @ Start time
loop$:
    bl GetTimeStamp
    mov r5, r0 @ Current time
    sub r5, r5, r4 @ Elapsed time
    cmp r4, r3
    ble loop$ @ Loop while elapsed time < wait duration
    pop {pc}
