; Week 3, Test Program 1
; Andrew House, TA, ECE352
;
; This program is the same as the week 2 test program, but without the
; nops inserted to prevent data hazards or enforce branch delays.
; It loads a value from memory, uses it to calculate some other values,
; then loops until one of those derived values is zero.  It then
; writes a result to memory, and reads it back to a different register.
;
; This -- as with last week -- should take roughly 63 (0x3f) cycles to execute.
;
; Final result should be:
; k0: 03   k1: 44    k2: 18    k3: 18
;
	ori	16	; value loaded into k1
	nand	k2,k1	; makes k2 equal to 0xff
	nand	k3,k1	; makes k3 equal to 0xff
	shiftl	k1,2	; multiply k1 by 4 to get address 64 in k1
	load	k0,(k1)	; load value 252 from address 64
	sub	k1,k1	; clear k1

	nand	k2,k0	; should leave 0x03 in k2
	nand	k3,k0	; should leave 0x03 in k3
	sub	k0,k0	; clear k0
	ori	1	; put 1 into k1

loop	add	k0,k1	; increment k0
	shiftl	k2,1	; multiply k2 by 2
	sub	k3,k1	; decrement k3
	bnz	loop	; loop until k3 = 0

	sub	k1,k1	; clear k1
	ori	17
	shiftl	k1,2	; multiply 17 by 4 to get address 68
	store	k2,(k1)	; write k2 to memory
	load	k3,(k1) ; read it to k3
	nop
	nop
	stop	; 21 instructions after loop
	nop
	nop
	nop
	nop
	nop

	org	64
ldlbl	db	252
	org	68
stlbl	db	1
