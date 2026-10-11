;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; vdp access
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    if COLECO
    else
_vdpReg 	equ 0xF3DF
LINL40		equ 0xF3AE
JIFFY:		equ 0xFC9E

enaslt:          equ #0024
exptbl:          equ #fcc1
slttbl:          equ #fcc5
    endif

; ------------
; macros
; (PAD_TO is defined earlier, near the top of main64.asm, since it's
; needed before this file gets included)

	macro setpage2 page
	ld   a, page
	ld	 (PAGESWAP),a
	endm

	
	macro enaint
	ei
	endm
	
	macro disint
	di
	endm
	
	macro _setVdp register,value	   ; macro definition
	ld	a,value 
	out (VDP+1),a
	ld	a,register + 0x80
	out (VDP+1),a
	endm

		macro setVdp register,value		  ; macro definition
		di
		_setVdp register,value
		ei
		endm


	macro _PROFsetVdp register,value	   ; macro definition
	if PROF
	_setVdp register,value
	endif
	endm

	macro PROFsetVdp register,value	   ; macro definition
	if PROF
	setVdp register,value
	endif
	endm

	macro _setvdpwvram value
	if (value & 0xFF)
		ld	a,value & 0xFF
	else
		xor a
	endif
	out (VDP+1),a
	ld	a,0x40 + (value/256)
	out (VDP+1),a
	endm

	macro setvdpwvram value
	di
	_setvdpwvram value
	ei
	endm

	macro _setvdprvram value

	if (value & 0xFF)
		ld	a,value & 0xFF
	else
		xor a
	endif

	out (VDP+1),a
	ld	a,value/256
	out (VDP+1),a

	endm

