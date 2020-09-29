/*
Pi Mailbox info:
	- Mailbox Addresses
		Address		Bytes	Name	R/W?	Description
		-----------------------------------------------
		2000B880	4		Read	R		Receiving mail.
		2000B890	4		Poll	R		Receive without retrieving.
		2000B894	4		Sender	R		Sender information.
		2000B898	4		Status	R		Information.
		2000B89C	4		Config	RW		Settings.
		2000B8A0	4		Write	W		Sending mail.
	- To send a message
		- Wait until top bit of Status field is 0
		- Write to Write field
			- Lowest 4 bits are the mailbox
			- Upper 28 bits are the mesage
	- To read a message
		- Wait until 30th bit of Status field is 0
		- Read from Read field
		- Confirm message is for correct mailbox, else retry
*/

.globl GetMailboxBase
GetMailboxBase:
	ldr r0,=0x2000B880
	mov pc, lr

.globl MailboxWrite
MailboxWrite: @ r0 = value, r1 = channel
	tst r0, #15 @ tst runs "and" and "cmp #0"
	movne pc, lr @ Validate that lowest 4 bits are 0
	cmp r1, #15
	movhi pc, lr @ Validate that mailbox < 16
	mov r2, r0 @ r2 = value
	push {lr}
	bl GetMailboxBase @ r0 = mailbox base address

wait1$:
	ldr r3, [r0, #0x18] @ r3 = status
	tst r3, #0x80000000
	bne wait1$ @ If top bit != 0, loop

	add r2, r2, r1 @ r2 = value + channel
	str r2, [r0, #0x20] @ write to Write field
	pop {pc} @ return

.globl MailboxRead
MailboxRead: @ r0 = channel
	cmp r0, #15
	movhi pc, lr @ Validate that mailbox < 16
	mov r1, r0 @ r1 = channel
	push {lr}
	bl GetMailboxBase @ r0 = mailbox base address

rightmail$:
wait2$:
	ldr r2, [r0, #0x18] @ r2 = Status field
	tst r2, #0x40000000 @ If 30th bit != 0, loop
	bne wait2$

	ldr r2, [r0, #0] @ r2 = mail (Read field)
	and r3, r2, #15
	teq r3, r1 @ If mail's mailbox is not channel:
	bne rightmail$ @ Check for more mail

	and r0, r2, #0xfffffff0 @ Extract value
	pop {pc} @ Return mail value
