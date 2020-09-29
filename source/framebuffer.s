.section .text

.globl InitFrameBuffer
InitFrameBuffer: @ r0 = width, r1 = height, r2 = bit depth
    cmp r0, #4096 @ Validate width <= 4096
    cmpls r1, #4096 @ and height <= 4096
    cmpls r2, #32 @ and bit depth <= 32
    movhi r0, #0 @ If not valid, set width to 0
    movhi pc, lr @ If not valid, return

    push {lr}
    ldr r3, =FrameBufferInfo @ r3 = fbInfoAddr
    str r0, [r3, #0] @ store width
    str r1, [r3, #4] @ store height
    str r0, [r3, #8]
    str r1, [r3, #12]
    str r2, [r3, #20] @ store bit depth

    mov r0, r3 @ r0 = fbInfoAddr
    add r0, r0, #0x40000000 @ tell GPU not to use cache (ensure flush)
    mov r1, #1 @ GPU mailbox channel
    bl MailboxWrite
    
    mov r0, #1
    bl MailboxRead @ r0 = GPU result

    teq r0, #0
    movne r0, #0 
    popne {pc} @ Return 0 if GPU result is not 0

    mov r0, r3 @ r0 = fbInfoAddr
    pop {pc} @ Return fbInfoAddr

.section .data
.align 4
.globl FrameBufferInfo
FrameBufferInfo:
    .int 1024   @ (0)   physical width
    .int 768    @ (4)   physical height
    .int 1024   @ (8)   virtual width
    .int 768    @ (12)  virtual height
    .int 0      @ (16)  GPU - Pitch
    .int 16     @ (20)  Bit Depth
    .int 0      @ (24)  X
    .int 0      @ (28)  Y
    .int 0      @ (32)  GPU - Pointer
    .int 0      @ (36)  GPU - Size
