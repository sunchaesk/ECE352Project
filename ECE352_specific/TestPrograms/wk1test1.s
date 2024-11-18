; Week 1, Test Program 1
; Andrew House, TA, ECE352
;
; This program loads a value from memory, SHIFTs it to get a new
; value, NANDs it to get 15, and then enters a loop where
; k0 decrement and k2 increments until k0 equals 0.  Then is writes
; k2 to memory, and reads it back into k3.
;
; Final result should be:
; k0: 00   k1: 1F    k2: 03    k3: 03
;
	sub	k1,k1	; clear k1
	ori	30	; address of 37
	load	k0,(k1) ; loads 37 into k0
	shiftr	k0,2	; shifts it right by 2
	sub	k1,k1	; clear k1
	ori	6	; puts 0110 in k1
	nand	k0,k1	; should leave 0xff in k0
        shiftr	k0,3	; shift right by 6, to leave 0x3 in k0
	shiftr	k0,3
	sub	k1,k1	; clear k1
	ori	1	; duh
loop	add	k2,k1	; increment k2
	sub	k0,k1	; decrement k0
	bnz	loop	; loop until k0 = 0
	sub	k1,k1	; clear k1
	ori	31
	store	k2,(k1)	; write k2 to memory
	load	k3,(k1) ; read it to k3
	nop
	nop
	stop
	nop
	nop	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	org	30
ldlbl	db	37
stlbl	db	1
