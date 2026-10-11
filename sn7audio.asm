n_sfx	equ	20

AR_TonA		equ 0	;RESW 1
AR_TonB		equ 2	;RESW 1
AR_TonC		equ 4	;RESW 1
AR_Noise	equ 6	;RESB 1
AR_Mixer	equ 7	;RESB 1
AR_AmplA	equ 8	;RESB 1
AR_AmplB	equ 9	;RESB 1
AR_AmplC	equ 10	;RESB 1
AR_Env		equ 11	;RESW 1
AR_EnvTp	equ 13	;RESB 1

	
; priority -  sfx number
; 0 	  - 01 Wave incoming, Player Explode, 13 Landing, 14 Landing alert,15 Take off, 16 Pause1, 17 Pause2, 18 Live Up, 19 Game over, 20 Warping.
; 1 	  - 11 ground explode,12 ground explode, 06 Exit,07 Start Level Sound
; 2 	  - 02,03,04,05 Enemy explode.
; 3 	  - 00 Ms fire,10 MS bullets hit solid wall
; 4 	  - 08 Enemy shoot.



AFXPLAY:
	or a
	ret z

	jp sfx_play
	
;	ld hl, sfx00_fire
;	ld c, SFX_CHANNELS2AND3
;	call PSGSFXPlay
	
	; ld	c,0
	;jp	ayFX_INIT	
	ret

AFXSTOP 	equ ayFX_END	; --- End of an ayFX stream ---
AFXFRAME 	equ ayFX_FRAME	; --- PLAY A FRAME OF AN ayFX STREAM ---
ROUT		equ	PT3_ROUT

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   compute PSG Volume balance
;


_SCC_PSG_Volume_balance:

    ld  a,(_psg_vol_fix)
    add a,15
    jr  nz,1f
    inc	a
1:        
    add	a,a				; a:=a*2
    add	a,a				; a:=a*4
    add	a,a				; a:=a*8
    add	a,a				; a:=a*16
    ld	e,a				; e:=a
    ld	d,0				; de:=a
    ld	hl,VT_			; hl:=PT3 volume table
    add	hl,de			; hl is a pointer to the relative volume table

    ld  (_psg_vol_balance),hl

    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   Interrupt handler
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Audio I/O
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; --- Place this instruction on interrupt --- 
	; --- or after HALT instruction to synchronize music ---
_no_music:
	xor	a



	ex	af,af'				; preserve af'
	push	af
	
	; ld a,(0xbfbe)
	; ld i, a

	
	; ld   a, (PT3_SFXBANK)
	; ld	 (PAGESWAP),a
	
	call PSGSFXFrame



	; ld a, i
	; ld (PAGESWAP),a

	
	pop		af
	ex	af,af'

	jp PT3_ROUT
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PT3 and SFX code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Audio_Internal_code:

; Only if musics are in ROM

	ld	a,(music_flag)
	and	a
	jr	z,_no_music

    ; ld  a,010111111B
    ; ld  (AYREGS+7),a

audio_internal_code_ok:
	
	ex	af,af'				; preserve af'
	push	af
	
	ld a,(0xbfbe)
	ld i, a

	
	ld   a, (PT3_MODBANK)
	ld	 (PAGESWAP),a
	
	call PSGFrame

	ld   a, (PT3_SFXBANK)
	ld	 (PAGESWAP),a
	
	call PSGSFXFrame



	ld a, i
	ld (PAGESWAP),a

	
	pop		af
	ex	af,af'

;-------------------------------------

PT3_ROUT:
	XOR A

	ret


;-------------------------------------

PT3_MUTE:
		xor a
		ld (music_flag), a
		call PSGStop
		
		;call PSGSFXStop
		ret

;HL - AddressOfModule - 100, E = Bank
PT3_INIT:
		LD A,E
		LD (PT3_MODBANK),A
		LD (PT3_MODADDR),HL

		ld a, 0xFF
		ld (music_flag), a

		call PSGStop

		ld a, $$sfx_play
		ld (PT3_SFXBANK), a
		
		call PSGPlay
		
mute_entry:		
		;xor a
		;call PSGPlay
		call PSGPlayNoRepeat
		
		ret
		
		

ayFX_SETUP:
		ld	a,1				; Starting channel
		ld	(ayFX_CHANNEL),a		; Updated
		
ayFX_END:
		ld	a,255				; Lowest ayFX priority
		ld	(ayFX_PRIORITY),a		; Priority saved (not playing ayFX stream)
		ret		
		
ayFX_FRAME:
		ret
		
PSG_START:
		xor a
		ld (music_flag), a

		ld hl, 0
		ld (_vocadr), hl


		call PSGInit
		call sfx_init
		
		ld a, $$sfx_play
		ld (PT3_SFXBANK), a
		ret

		
		