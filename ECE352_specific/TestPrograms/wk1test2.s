; Week 1, Test Program 2
; Andrew House, TA, ECE352
;
; This program loads a positive value from memory, then enters a loop where
; it decrements until it becomes negative. Then it writes that value
; to memory, reads it back into k2, and then tries to calculate its twos
; complement, which it stores in k3.
;
; Final result should be:
; k0: FF   k1: 01    k2: FF    k3: 01
;
	sub	k1,k1	; clear k1
	ori	30	; address of 37
	load	k0,(k1) ; loads 37 into k0
	shiftl	k0,1	; shifts it right by 2
	sub	k1,k1	; clear k1
	ori	1	; duh
loop	sub	k0,k1	; decrement k0
	bpz	loop	; loop until k0 < 0
	sub	k1,k1	; clear k1
	ori	31
	store	k0,(k1)	; write k2 to memory
	load	k2,(k1) ; read it to k2
	ori	31	; make lsb 5-bits of k1 equal 1
	add	k3,k1	; add it into K3
	shiftl	k3,3	; shift bits of K3 3 to the left
	sub	k1,k1	; clear k1
	ori	7	; make k1 equal 7
	add	k3,k1	; now K2 should be 11111111
	nand	k3,k2	; nand 0xff with k2
	sub	k1,k1	; clear k1
	ori	1	; set k1 to 1
	add	k3,k1	; 
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
	org	30
ldlbl	db	5
stlbl	db	1
