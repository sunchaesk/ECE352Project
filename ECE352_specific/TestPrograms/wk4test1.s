; Week 4, Test Program 1
; Andrew House, TA, ECE352
;
; This program starts increment from 120, and when the overflow
; occurs, in adds 1 to the negative result, takes its two's complement,
; then adds the two's complement back to the result, giving zero
; at the end.
;
; Final result should be:
; k0: 81   k1: 01    k2: 48    k3: 00
;
; In memory, starting from location 64, there should be the values
; 120, 121, 122, 123, 124, 125, 126, 127
;
	sub	k1,k1	; clear all registers
	sub	k0,k0
	sub	k2,k2
	sub	k3,k3
	ori	16	; load 16 into k1
	add	k2,k1	; set k2 to 16
	shiftl	k2,2	; multiply k2 by 4, giving 64
	load	k0,(k2)	; load value 120 from memory location 64
	sub	k1,k1	; clear k1 again
	ori	1	; set k1 to 1

loop1	store	k0,(k2)	; store value of k0 to memory
	load	k3,(k2) ; read it back to k3
	add	k3,k1	; increment value by 1
	add	k2,k1	; increment memory pointer by 1
	add	k0,k1	; increment k0 by 1
	bpz	loop1	; loop while a positive number

; at this point, k0 == k3 == -128 == 0x80, k1 == 1, k2 == 72 == 0x48

	add	k3,k1	; increment k3, leaving it at -127
	; get twos complement of k3
	ori	31	; sets k1 to 0x1f
	shiftl	k1,3	; sets k1 to 0xf8
	ori	7	; kets k1 to 0xff
	nand	k3,k1	; toggles all the bits of k3, leaving it as 0x7e
	shiftr	k1,3	; shift k1 right by 3, leaving 0x1f
	shiftr	k1,2	; shift k1 right by 2, leaving 0x07
	shiftr	k1,2	; shift k1 right by 2, leaving 0x01
	add	k3,k1	; increment k3 by 1

; at this point, k0 == -128, k1 == 1, k2 == 72, and k3 == +127

	add	k0,k1	; increment k0 by 1 to get -127
	add	k3,k0	; should leave k3 as 0	
	nop
	nop
	nop
	stop
	nop
	nop
	nop
	nop
	nop

	org	64
lbl	db	120

