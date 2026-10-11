
SC_PPI_A		equ		$DC
SC_PPI_B		equ		$DD
SC_PPI_C		equ		$DE
SC_PPI_CTRL		equ		$DF


; b = test value
;---------------------------------------
ppi_test:
;---------------------------------------
				ld		b, a
				out		(SC_PPI_C),a
				call	ppi_pause
				in		a,(SC_PPI_C)
				cp		b
				ld		a, $00						; "xor a" cannot be used. Zero Flag must be intact.
				jr		z, ppi_test_noerr
				dec		a								; c = 0xFF if not detected
ppi_test_noerr:
				ret
		
ppi_pause:
				nop
				nop
				ret



;---------------------------------------
ppi_init:
;---------------------------------------
				ld		a, $92					; Init PPI (if present). PortC = Ouput, PortA + PortB = Input		
				out		(SC_PPI_CTRL),a	
				call	ppi_pause

				xor		a
				ld		(KBD_PRESENT),a			; default value, 0 = keyboard absent

				ld		a,$55
				call	ppi_test
				ld		c, a
				ld		a,$AA
				call	ppi_test
	
				or		c							; merge the two attempts
				cpl									; invert it
				and		1
				ld		(KBD_PRESENT),a				; save it, 0x01 = keyboard present, 0x00 keyboard absent (SG-1000)

				ld		a, 7						; Set row 7 (joypad) as default
				out		(SC_PPI_C), a
				ret


;---------------------------------------
joy0_read:
;---------------------------------------
		push bc
		call ppi_kbd_read
		ld   c, a
		
		call ppi_joy0_read
		and  c
		pop  bc
		ret


; Output: A = joystick primary port 
;		  Inverted bits (..21RLDU)
;---------------------------------------
ppi_joy0_read:
;---------------------------------------
				ld		a, 7
				out		(SC_PPI_C), a
				in		a, (SC_PPI_A)
				

				push	bc
				ld		c, a
				ld		a, 2
				out		(SC_PPI_C), a
				in		a, (SC_PPI_A)

				bit		4, a
				jp		nz, ppi_joy0_read_END
				res		5, c			; Home/Clr => Fire 2			(--BARLDU)
ppi_joy0_read_END:
				ld		a, c
				pop		bc
				
				or		$C0
				ret


; Output: A = joystick second port 
;		  Inverted bits (..21RLDU)
;---------------------------------------
ppi_joy1_read:
;---------------------------------------
				push	bc
				ld		a, 7
				out		(SC_PPI_C), a
				in		a, (SC_PPI_A)
				ld		b, a						; DU------

				in		a, (SC_PPI_B)				; ....BARL
				sla		a
				sla		a							; ..BARL..
				or		$C3							; 11BARL..
				bit		6, b
				jp		nz, _noJ2Up
				res		0, a						; 11BARL.U
_noJ2Up:
				bit		7, b
				jp		nz, _noJ2Dn
				res		1, a						; 11BARLDU
_noJ2Dn:
				pop		bc
				ret





; Output: A = keyboard cursors + Ins/Del (Fire 1) + Home/Clr (Fire 2)
;		  Inverted bits (..21RLDU)
;---------------------------------------
ppi_kbd_read:
;---------------------------------------
				ld		a, (KBD_PRESENT)
				or		a
				ld		a, $FF
				ret		z

				push	bc
				
				ld		c, a

; ===== ROW 6
				ld		a, 6
				out		(SC_PPI_C), a
				in		a, (SC_PPI_A)

ppi_kbd_read_Cursor_Right:
				bit		5, a
				jp		nz, ppi_kbd_read_Cursor_Up
				res		3, c			; CURSOR RIGHT => Joy Right	 	(----R---)

ppi_kbd_read_Cursor_Up:
				bit		6,a
				jp		nz, ppi_kbd_read_Cursor_Left
				res		0, c			; CURSOR UP => Joy Up			(----R--U)

ppi_kbd_read_Cursor_Left:
; ===== ROW 5				
				ld		a, 5
				out		(SC_PPI_C), a
				in		a, (SC_PPI_A)
				
				bit		5, a
				jp		nz, ppi_kbd_read_Cursor_Down
				res		2, c			; CURSOR LEFT => Joy Left		(----RL-U)

ppi_kbd_read_Cursor_Down:

; ===== ROW 4
				ld		a, 4
				out		(SC_PPI_C), a
				in		a, (SC_PPI_A)

				bit		5,a
				jp		nz, ppi_kbd_read_Cursor_Fire1
				res		1, c			; CURSOR DOWN => Joy Down		(----RLDU)

ppi_kbd_read_Cursor_Fire1:
; ===== ROW 3
				ld		a, 3
				out		(SC_PPI_C), a
				in		a, (SC_PPI_A)

				bit		4,a
				jp		nz, ppi_kbd_read_Cursor_Fire2
				res		4, c			; Ins/Del => Fire 1				(---ARLDU)

ppi_kbd_read_Cursor_Fire2:
; ===== ROW 2
				ld		a, 2
				out		(SC_PPI_C), a
				in		a, (SC_PPI_A)

				bit		4,a
				jp		nz, ppi_kbd_read_END
				res		5, c			; Home/Clr => Fire 2			(--BARLDU)

ppi_kbd_read_END:
				ld		a, c
				pop		bc

				ret





;---------------------------------------------------------------
ppi_rowread7:
;---------------------------------------------------------------
				ld		b, 7
;---------------------------------------------------------------
ppi_rowread:
;---------------------------------------------------------------
				ld		a, b
				out		(SC_PPI_C), a	; no effect on SG-1000
				dec		b
JoyRead:
				in		a, (SC_PPI_A)
				ret


;---------------------------------------------------------------
ppi_rowread7B:
;---------------------------------------------------------------
				ld		b, 7
;---------------------------------------------------------------
ppi_rowreadB:
;---------------------------------------------------------------
				ld		a, b
				out		(SC_PPI_C), a	; no effect on SG-1000
				dec		b
				in		a, (SC_PPI_B)
				ret
