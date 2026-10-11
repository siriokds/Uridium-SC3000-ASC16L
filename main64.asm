COLECO: 		equ 1
DEMO: 			equ 0
PROF: 		  equ 0

LEVEL_ZINC:     equ  0
LEVEL_LEAD:     equ  1
LEVEL_COPPER:   equ  2
LEVEL_SILVER:   equ  3
LEVEL_IRON:     equ  4
LEVEL_GOLD:     equ  5
LEVEL_PLATINUM: equ  6
LEVEL_TUNGSTEN: equ  7
LEVEL_IRIDON:   equ  8
LEVEL_KALLISTO: equ  9
LEVEL_TRIALLOY: equ 10
LEVEL_QUADMIUM: equ 11
LEVEL_ERGONITE: equ 12
LEVEL_GALACTUS: equ 13
LEVEL_URIDIUM:  equ 14

VOICESENABLED:	equ 1
SHOWMANTA105:	    equ 0
LEVELSTART:		equ 0
FORCEGODMODE:	equ 0
FORCEVICTORY:	equ 0

VIDEOPLAYER:	equ 0

PAUSEENABLED:	equ 1




FORCEVDPFREQ:	equ 0; 50			; 0 = auto

STACK0:			equ 0xDFF0
STACK:			equ 0xFE80	
		
VDP:			    equ 0xbe
PAGESWAP:	    equ 0x8000

ENDVARS:		    equ 0xFFFE ;0xFFE0

JIFFY:		    equ ENDVARS
JIFFY2:		    equ ENDVARS-2
VDP50HZ:		    equ ENDVARS-3 
VDPFREQ:		    equ ENDVARS-4
victory:		    equ ENDVARS-5		

	IF PAUSEENABLED	
PAUSE_COUNTER:	equ ENDVARS-6
PAUSE_FLAG:		equ ENDVARS-7
PAUSE_CHANGED:	equ ENDVARS-6
	ENDIF

ingame:			equ ENDVARS-4
insequence:		equ ENDVARS-3


_vdpReg:		equ 0xFFD0

; music_off:		equ 0xFFF8
; voice_off:		equ 0xFFF9

;INTVECTOR:		equ 0xFFFE ;0xFFE0    

;ram_sat:		equ 0x10000-128

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; -----------------------------
; 	game setings 

	include "parametrs.asm"
maxspeed:					equ 16		; the actual speed is divided by 4
max_enem:					equ 12		; max 12
max_enem_bullets:			equ 3
max_bullets:				equ 2		; max number of enemies*2 + ms_bullets + enem_bullets + 3 for ms	<= 32 sprites

max_turret:					equ 4		; turrets on the ground: value included in max_enem

assault_wave_timer_preset:	equ	3*60	; a wave each 3 seconds
enemy_bullet_speed:			equ	2	
xship_rel:					equ (128-8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; -----------------------------
; smooth scroller engine
; Uridium 128K: SC-3000 version
; Trilobyte 2014-2017
; ------------------------------
; include paths (levels/, mus/, afx/, graphic/, options/, extra/) are passed
; to sjasmplus via -I on the command line (see build.sh) instead of incdir,
; which sjasmplus does not support as a pseudo-op.

	; ported from sjasm classic's defpage/code-page paging model to
	; sjasmplus's DEVICE/SLOT/PAGE model: 4 slots of 0x4000 bytes
	; (0x0000, 0x4000, 0x8000, 0xC000), 10 pages (0..9) to cover both
	; the VIDEOPLAYER and non-VIDEOPLAYER page layouts below.
	DEFDEVICE URIDIUMDEV, $4000, 10
	DEVICE URIDIUMDEV

	output "URIDIUM.asc"

	; page layout (was defpage):
	; page 0 -> slot 0 (0x0000-0x3FFF), fixed
	; page 1 -> slot 1 (0x4000-0x7FFF), fixed
	; IF VIDEOPLAYER:     pages 2..9 -> slot 2 (0x8000-0xBFFF), switched at runtime
	; ELSE (active path): pages 2..7 -> slot 2 (0x8000-0xBFFF), switched at runtime

	; pad the current bank up to addr (0xFF filler); fails loudly if the
	; bank has overflowed addr instead of silently truncating.
	macro PAD_TO addr
	ASSERT $ <= addr
	IF $ < addr
	BLOCK addr-$, 0xFF
	ENDIF
	endm

	; ORG to the base of a page-switched bank (0x8000): reusing that
	; address for every bank 2..7 is intentional (megarom banking), so
	; the fileorg warning is expected here and suppressed just for this
	; one ORG, not globally.
	macro BANK_ORG addr
	OPT push -Wno-fileorg
	ORG addr
	OPT pop
	endm













; ------------------------------
	SLOT 0 : PAGE 0

	ORG 0x0000
	nop
	di
	im 1
	ld 	sp,STACK0
	jp initmain


	; code @ 	0x0010
	; jp set_rom_tileset

	PAD_TO 0x0038
	ORG 0x0038
	jp isr

	PAD_TO 0x0066
	ORG 0x0066
	IF PAUSEENABLED
	jp NMI_VECTOR
	ELSE
	jp 0
	ENDIF
	; code @  0x0069
	; db 60

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "macros.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initmain:
	_setVdp 1,0x82
	in a,(VDP+1)

	ld b, 12
resetpsg:
	call PSGSilenceChannels
	djnz resetpsg
; resetpsg:
	; ld a,$9F 					; form off code For tone generator 1
	; out ($7F),a 				; send it out
	; ld a,$BF 					; form off code For tone generator 1
	; out ($7F),a 				; send it out
	; ld a,$DF 					; form off code For tone generator 1
	; out ($7F),a 				; send it out
	; ld a,$FF 					; form off code For tone generator 1
	; out ($7F),a 				; send it out
	

	xor a
	ld ($0000), a
	inc a
	ld ($4000), a
	inc a
	ld ($8000), a
	
	
	
	
	ld hl,0xC000
	ld de,0xC001
	;ld bc,16384-16-1
	ld bc,16384-32-1
	ld (hl),0
	ldir						; reset ram range C000h-FFFFh


VDP_INIT_DELAY:						; close to 1000 ms
	ld b, 2		;11			; Loretta waits for 1903 ms, Gulkave waits for 536 ms
	ld de, $FFFF
2:	ld hl, $39DE
1:	add hl, de
	jr c, 1b
	djnz 2b


	in a,(VDP+1)
	in a,(VDP+1)
	
	call vdp_mode2

	
	_setvdpwvram (0x0000)
	ld  bc, 16384
	xor a
	call vdp_fillvram
	
	
	ld		hl, JIFFY
	xor		a
	ld		(hl),a
	inc		hl
	ld		(hl),a
	ld 		(VDP50HZ),a


	ld  de, isr_simple
	ld  hl, INTVECTOR
	ld  (hl), e
	inc hl
	ld  (hl), d

	;setpage2 :show_manta
	;call 	show_manta
	;_setVdp 7,0xEE
	
	call loading_screen
	
	_setVdp 1,0x82+0x40+0x20				; 16KB, BLANK, INT, M1=0, M3=0
	ei

	ld		bc, 20000
	call	pause
	
	di
	_setVdp 1,0x82							; 16KB, NO BLANK, NO INT, M1=0, M3=0

	ld		a, (JIFFY)
	ld		(JIFFY2), a
	
	IF FORCEVDPFREQ > 0	
	ld 	a, FORCEVDPFREQ
	ELSE
	cp 	$6C
	ld  a, 60
	jr  nc, setvdpfreq
	ld  a, 50
	ENDIF
setvdpfreq:

	ld  (VDPFREQ), a
	




	ld	de, isr_game
	ld  hl, INTVECTOR
	ld  (hl), e
	inc hl
	ld  (hl), d

SETUP_SCREEN:
	in a,(VDP+1)
;		_setVdp 1,0x82
	in a,(VDP+1)
	_setVdp 1,0x82
	_setVdp 7,0x33


	in a,(VDP+1)

	call ppi_init



	; _setvdpwvram (0x0000)
	; ld  c,VDP
	; ld  a,64
; 2:
	; ld  b,0
; 1:		nop
	; outi
	; jp	nz,1b
	; dec a
	; jp  nz,2b



	;ld a,(0xfff8)
	;setpage 0
	ld  a, $$splash_shps
	ld (PAGESWAP),a



	;ld 		a,(0x0069)
	
	
	ld 		a, (VDPFREQ)
	sub 	60
	ld		b,1
	jr 		z,1f
	ld 		a,0x80
	ld		b,6
1:	ld		ixh,a			; preserve the ROM findings
	ld		ixl,b			


vdpinit:
	ld		a,ixh
	ld 		(vsf),a     	; 0 => 60Hz, !0 => 50Hz
	ld      a,ixl			; preset the tic counter for 50Hz/60Hz conversion
	ld      (cnt),a			

	ld a,0xa2
	ld	(_vdpReg+1),a
	_setVdp 0,0x02
	_setVdp 2,0x06
;	_setVdp 7,0x01
	_setVdp 7,0x11


	; _setvdpwvram (0x0000)
	; ld      bc,$4000

; filvrm_lp:

	; ex (sp),hl				; 19 cycles
	; ex (sp),hl				; 19 cycles
	; out     (VDP),a

	; dec 	bc
	; ld		a, b
	; or		c
	; jr      nz,filvrm_lp




	call    PSG_START

	jp 	gameinit



	include "isr.asm"

	include "ppi.asm"



pause:
	call pause10nops
	call pause10nops
	call pause10nops
	call pause10nops
	call pause10nops

	dec  bc
	ld   a, b
	or   c
	jr   nz, pause
	ret

pause10nops:
;[10] 	nop
	ex (sp),hl
	ex (sp),hl
	ret


vdp_mode2:
	_setVdp 0,0x02
	_setVdp 1,0x82				; 16KB, NO BLANK, NO INT, M1=0, M3=0
	_setVdp 2,0x06
	_setVdp 3,0xFF
	_setVdp 4,0x03
	_setVdp 5,0x36
	_setVdp 6,0x07
	_setVdp 7,0x00
	
	_setvdpwvram 0x1B00
	ld	a,0xd0
	out	(VDP),a					; no sprites
	
	ret

vdp_fillvram:
	push hl
	ld 	 l, a
1:
	ex (sp),hl
	ex (sp),hl
	ld   a, l
    out	(VDP), a
	
;	call vdp_writebyte

	dec  bc
	ld   a, b
	or   c
	jr   nz, 1b
	
	pop  hl
	ret


vdp_copyvram:
	push hl
1:
	ld  a, (hl)
	inc hl

	call vdp_writebyte
	; ex (sp),hl
	; ex (sp),hl
    ; out	(VDP), a
	
	dec  bc
	ld   a, b
	or   c
	jr   nz, 1b
	
	pop  hl
	ret

vdp_writebyte:
	
	nop	; 4
	nop	; 4
	nop	; 4
	nop	; 4
	nop	; 4
	nop	; 4
	nop	; 4
	nop	; 4
    out	(VDP), a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
set_rom_tileset:

	ld a,(0xbfbe)
	push af
	
	setpage2 $$_rom_tileset
	
	ld	hl,_rom_tileset
	ld  de, 0x1000
	call BitBuster_UnpackVRAM

	pop af
	ld (PAGESWAP),a
	
;	ld a,(de)			; restore the old page
	ret
	
write_256:
	ld	b, 0
	ld  c, VDP

	; 256*8 = 2048
	otir
	otir
	otir
	otir
	
	otir
	otir
	otir
	otir
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enascr:
	ld	   a,(_vdpReg + 1)
	or	   #40
	jr	   1f
disscr:
	ld	   a,(_vdpReg + 1)
	and	   #bf
1:	out	   (VDP+1),a
	ld	   (_vdpReg + 1),a
	ld	   a,1 + 128
	out	   (VDP+1),a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setwrtvram:
	ld	a,e
	out (VDP+1),a
	ld	a,d
	or 0x40
	out (VDP+1),a
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; write 2K while ints are active from miz_buffer
; in: de vram address
write_2k:
	ex	de,hl
	set	6,h
	ld	c,VDP+1
	ld	de,16
	exx
	ld	hl,miz_buffer
	ld 	e,127
	ld	c,VDP
2:	
    disint
	exx
	out (c),l
	out (c),h	;c' = 0x99, HL' with write setup bit set
	add hl,de	;de' = 16
	exx
	ld b,16
1:	nop
	outi		;c = 0x98
	jp nz,1b
    enaint
	dec e
	jp nz,2b
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		   defb 0x02 ; Reg# 0 000000[M3][EV]
;		   defb 0x62 ; Reg# 1 [4/16k][BLANK][IE][M1][M2]0[SIZE][MAG]
;		   defb 0x06 ; Reg# 2 0000[NAME TABLE BASE ADDRESS]			 = 1800h

;		   defb 0x9F ; Reg# 3 [COLOR BASE ADDRESS]					 = 2000h ; hybrid mode for colors
;		   defb 0xFF ; Reg# 3 [COLOR BASE ADDRESS]					 = 2000h ; regular mode for colors

;		   defb 0x1F ; Reg# 3 [COLOR BASE ADDRESS]					 = 0000h ; hybrid mode for colors
;		   defb 0x7F ; Reg# 3 [COLOR BASE ADDRESS]					 = 0000h ; regular mode for colors

;		   defb 0x00 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]	 = 0000h ; hybrid mode for patterns
;		   defb 0x03 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]	 = 0000h ; regular mode for patterns

;		   defb 0x04 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]	 = 2000h ; hybrid mode for patterns
;		   defb 0x07 ; Reg# 4 00000[PATTERN GENERATOR BASE ADDRESS]	 = 2000h ; regular mode for patterns

;		   defb 0x36 ; Reg# 5 0[SPRITE ATTRIBUTE TABLE BASE ADDRESS] = 1b00h
;		   defb 0x07 ; Reg# 6 00000[SPRITE PTRN GNRTR BASE ADDRESS]	 = 3800h
;		   defb 0x01 ; Reg# 7 [TEXT COLOR 4bts][BACKDROP COLOR 4bts]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "mizer.asm"
	;include unpacker_dzx0_standard_vram.asm
	;include unpacker_bitbuster.asm
	include "unpacker_bitbuster_vram.asm"
	;include unpacker_pletter_vram.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sfxBank_miz:
	; incbin	sfx.miz

;sfxBank_afb:
;	incbin	sfx.afb

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ms_ani:
	include "ms_demo_ani.asm"
ms_spt:
	incbin "ms_demo_frm.bin"
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "intro.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mus_mute:
	db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	incbin "UR_MUTE.PSG"

	; db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
	; incbin UR_mute.BIN

; mus_end:
	; db 00,05,15,15,06,00,00,15,00,00,00,00,00,00,00,00
	; incbin UR_ENDING.MIZ
	




	
n_musics equ 5
music_tables:
	dw mus_mute,  $$mus_mute		; Blue
	dw mus_mute,  $$mus_mute		; Red
	dw mus_mute,  $$mus_mute		; Green
	dw mus_end,   $$mus_end		; End
	dw mus_intro, $$mus_intro	; Intro

wavemap_init:
	ld bc,16
	add hl,bc
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "options.asm"
	;include slot.asm


	include "sfx.asm"
	



	
endpage0:
	PAD_TO 3fbeh
	ORG 3fbeh
	dw 0

	PAD_TO 3ff0h
	ORG 3ff0h		;	ds      $3FF0 - $
	db "AS16"
	db $53, $45, $47, $41, $20, $20
	db $56, $E4, $00, $00, $00, $4C




























	; pad page 0 to its full 0x4000 size (classic sjasm's defpage did this
	; implicitly; sjasmplus's flat OUTPUT does not, so it's done explicitly
	; here to keep every bank exactly 0x4000 bytes in the final ROM image)
	PAD_TO 0x4000

	;code  @	8000h, page 7
	SLOT 1 : PAGE 1 : ORG 0x4000
filler_4000:
	nop


gameinit:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
; actual main
	
	xor	a
	ld	(visible_sprts),a
	ld	(ingame),a
	ld  (insequence), a
	ld	(PT3_SETUP),a
	
	IF PAUSEENABLED	
	ld (PAUSE_COUNTER), a
	ld (PAUSE_FLAG), a
	ENDIF

	inc a
	ld  (start_intro_mus),a
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	xor	a
	if DEMO
		inc	a
	endif
	ld	(victory),a			; none has completed the game yet

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	call    PSG_START
	call	ayFX_SETUP
	
	xor	a					; range [-15,0]
	ld      (_psg_vol_fix),a
	ld		(_sfx_vol_fix),a
	
	call 	_SCC_PSG_Volume_balance
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	xor	a
	ld	(god_mode),a		; god mode trick is off
	inc a					; default 1 == NORMAL
	ld	(game_speed),a		; valid values 0 1 2 
	ld	(sprite_3c),a		; the 3 colour sprite trick is on
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
title_screen:
	ld sp,STACK			; place manually the stack

	call 	ayFX_END
	call	PT3_MUTE
	call	_mute			; no voice
	call	rand8_init
	


    disint
	call	disscr
	_setVdp 3,0xFF	;	colours at 0x2000	(regular mode for colours)
	_setVdp 4,0x03	;	patterns at 0x0000	(regular: used 0x0800 0x1000)
	_setVdp 5,0x36	;	SAT at 0x1b00
	_setVdp 6,0x07	;	SPT at 0x3800	(64 sprites 16x16)
	_setvdpwvram 0x1b00
	ld	a,0xd0
	out	(VDP),a
    enaint


; title_screen_exec:
	; ld sp,STACK			; place manually the stack

	xor	a
	ld	(visible_sprts),a
	ld	(ingame),a
	dec	a
	ld	(joystick),a
	ld	(old_joystick),a
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; plot splash screen
	; menu goes here !!	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	
	ld	a,(victory)
	
	IF FORCEVICTORY	
	ld a, 1
	ENDIF
	
	and	a
	jp	nz,ending_splash_screen
	
; Normal splash screen	
	

	setpage2 $$show_manta
	call 	show_manta
    enaint
	
	xor a
	ld	(enable_cheat),a
	
	ld		bc,5*60
1:	push	bc
	halt
	call	_set_godmode		; test here for cheat!
	call	_joy_read
	bit		4,a
	pop		bc
	jp		nz,_main_menu		; end at key pressed
	dec		bc					; end after bc millisecs
	ld		a,b
	or		c
	jr		nz,1b


	call    sfx_waitsfx

	jp 		_main_menu

ending_splash_screen:	

	;call	sfx_waitsfx
	call	PT3_MUTE
	call	sfx_init

	IF VIDEOPLAYER
		call animated_explosion
	ENDIF
	
	IF SHOWMANTA105
		disint
		setpage2 $$show_manta_wins
		call 	show_manta_wins
		enaint
	ENDIF
	
	
    disint
	setpage2 $$ending_screen
	call	disscr
	call	ending_screen
	
	call	enascr		
	enaint


	call    .explosion_3

	; ld hl,_explosion
	; call .explosion_2
	
	; ld hl,_explosion
	; call .explosion_2
	
	; ld hl,_explosion
	; call .explosion_2

	disint
	call	disscr

	jp show_victory_screen
	
	
; .explosion_2:
	; ld (_vocadr),hl
	; ld hl,0
	; ld (bannertimer),hl

; 1:
	; HALT
	
	; HALT
	
	; ld hl,(bannertimer)
	; inc hl
	; ld (bannertimer),hl
	
	; ld 	hl,(_vocadr)
	; ld	a,l
	; or	h
	; jp	nz, 1b
	; ret
	

.explosion_3:

	ld	hl, 0
	ld (bannertimer),hl

.explosion_3_loop:
	halt
	
	; ld hl,JIFFY			; wait a vblanck
	; xor	a
; 1:	cp (hl)
	; jr z,1b
	; ld	(hl),a

	call	rand8
	and	15
	jr	nz, .explosion_3_no_sound
	
	ld	a,12				; exit
	call AFXPLAY


.explosion_3_no_sound:
	ld hl,(bannertimer)
	inc hl
	ld (bannertimer),hl

	ld	de, 60*6
	call dcompr
	jp	c, .explosion_3_loop


	ld	hl, 0
	ld (bannertimer),hl

.explosion_3_end:
	halt
	
	ld hl,(bannertimer)
	inc hl
	ld (bannertimer),hl

	ld	de, 60
	call dcompr
	jp	c, .explosion_3_end
	
	ret

;--------------------------------
; $0020 DCOMPR
; Function : Compared HL to DE
; Output   : flags influenced like CP instruction
; Registers: A
dcompr:
                ld      a,h
                cp      d
                ret     nz
                ld      a,l
                cp      e
                ret	
	
	
show_victory_screen:	
	
	setpage2 $$victory_screen
    disint
	call	disscr
	call	victory_screen

	setpage2 $$victory_text
	call	victory_text
	call	enascr
	call	ending_music
    enaint
	ld		bc,20*60
	
;	ld a,(0xfff8+:wait_time_or_key_bc)		
	setpage2 $$wait_time_or_key_bc
	call	wait_time_or_key_bc	; 20 secs
	
	;ld a,(0xfff8+:victory_text1)
	setpage2 $$victory_text1
	call	victory_text1

    enaint
	call	wait_music_or_key	; till music ends
	call	victory_text2
    enaint
	call	wait_time_or_key	; 10 secs
	call	PT3_MUTE
	xor	a							; delete previous victories 
	ld	(victory),a			; avoid greetings if you play another time and die
	dec	a
	ld	(enable_cheat),a	; enable cheat after each victory

_main_menu:
	call 	ayFX_END		; stop any sfx enentually active
	ld	a,3
	ld	(turret_type),a		; homing turrets
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; title and main menu 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	call	plot_title_screen


	ld	a,8
	ld	(turret_type),a		; static turrets
	
	ld	a,(game_speed)
	and a					; 0 == hard mode
	jr	nz,.notinsane
	inc a					; set speed same in hard mode
	ld	(game_speed),a
	ld	a,3					; change turrets in 
	ld	(turret_type),a		; homing turrets
.notinsane:
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; game start
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
    disint
	call	disscr	
	call 	cls
	enaint
	call	sprite_init
	
	call 	ayFX_SETUP
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ld	bc,0						; show score on screen 
	call	add_bc_score_bin
	ld	c,0							; show lives on screen 
	call	add_c_lives_bin

	xor	a
	ld	(already_dead),a			; reset at level start, set after you die
	inc	a
	
	
	
	; XXX for testing
	;ld a,15
	
    if LEVELSTART > 0
		ld a,LEVELSTART
    endif	
	
	ld	(next_level),a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; XXX for testing
    if FORCEGODMODE
		ld	a,1
		ld	(god_mode),a
		ld	(music_off),a
    endif	

	
restart:
	ld	hl,0
	ld	(xmap),hl
	call 	ayFX_END
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	reset energy bar
	ld a,7
	ld (shieldlevel+1),a
	call	_plotenergy

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	play warping sequence only once 
;	at level start
;
	ld	a,(already_dead)
	and	a
	jr	nz,11f

	ld      a, 1
	ld     (insequence), a


	call	PT3_MUTE			
	call	intro_anim			; space warp sequence here 



11:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; music starts AFTER the warping sequence
;	
	ld	a,(music_off)
	and	a
	jr	nz,11f			; do not start music if music is off

	ld	a,(already_dead)
	and	a
	jr	nz,11f			; do not restart music if already dead

	ld		a,(cur_level)
	dec		a
1:	cp		n_musics
	jr		c,1f
	sub		n_musics
	jr		1b

1:	call	start_song

11:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; update the level map, but not the tile definitions
;
	ld	a,(already_dead)
	and	a
	call	nz,just_level_init	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set the level name

	call 	set_level_name

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; scrolling and main ship initialization

	xor a
	ld	(aniframe),a
	ld	(anispeed),a
	ld	(anispeedcnt),a
	ld	(ms_state),a
	ld	a,8
	ld	(dxmap),a
	ld	(old_aniframe),a		; old_aniframe!=aniframe
	
	ld	hl,0
	ld	(xmap),hl
	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl
	ld	a,64+64-8
	ld	(yship),a
	ld 	a,16
	ld 	(zship),a		; shadow quote
	
	call	ayFX_SETUP	
	xor	a
	ld	(halt_game),a
	ld	(halt_gamef1),a
	ld	(JIFFY),a
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	init ground enemies

	call	turret_init

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	main loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main_loop:

; pause loop
pause_loop	
	ld	a,(halt_game)
	and	a
	jr	nz,pause_loop

; test for end level 
	call	test_runway

; run ms FSM and eventually manage game over
	call	ms_ctrl

; test for game restart
	ld	a,(ms_state)
	cp	ms_reset
	jp	z,restart

; place MS in the SAT and test for collision
	call	put_ms_sprt
	ld		a,(god_mode)
	and 	a
	call	z,test_obstacles
	
; run NCPS FSM
	call	npc_loop			; manage active enemies

; enemy bullet FSM
	call	enemy_bullet_loop	; manage enemy bullets

; run MS bullets FSM
	call	ms_bullet_loop

; place NPCS sprites in the SAT in RAM
	call	plot_enemy		

; manage banner effects
	ld a,(JIFFY)
	and a
	call 	z,bannerupdate		; run this code only if you have time
; spawn new enemies
	ld a,(JIFFY)
	and a
	call	z,wave_timer		; activate new enemies only if we have time
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wait refresh and update map position

	ld hl,JIFFY
	; setVdp 7,13
	ld	a,(game_speed)
	dec	a
wait:
	cp (hl)
	jr nc,wait
	xor	a
	ld	(hl),a					; reset JIFFY

	ld	hl,(xmap)
	ld	a,(dxmap)
	.2 sra a
	ld	e,a
	add a,a
	sbc a,a
	ld	d,a
	add hl,de
	ld	(xmap),hl

	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Manage map limits

	ld	hl,(xmap)
	inc h
	ld	de,8*(LvlWidth)+256
	and a
	sbc hl,de
	ld	a,-12
	jp	nc,.endmap	; bounce right border

	add hl,de
	ld	bc,-256-8
	add hl,bc

	jp	c,main_loop
	
	ld	a,12		; bounce left border
	
.endmap:
	ld	(dxmap),a
	jp	main_loop
;
; main loop end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setbanner:
	_setvdpwvram (0x1800)
.out256		
	ld  bc,VDP
1:	nop
	outi
	jp	nz,1b
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; expand level in A but need level data paged in 
; 

levelinit:
	ld	(cur_level),a
	dec a				; no ground objects in warp level
	ld  l,a
	ld  h,0
	.2	add hl,hl
	ld 	de,level_param+1
	add hl,de
	ld a,(hl)			; small ports
	inc hl
	add a,(hl)			; enemy ships
	inc hl
	add a,(hl)			; large ports
	ld (level_goal),a
	
	ld	hl,level_buffer
	ld	de,level_buffer+1
	xor a
	ld	(hl),a
	ld	bc,LvlWidth*16-1+32
	ldir
	
	ld (backcolor),a			; black as background
	halt 
	call _set_uridium_sign
	
	disint
	_setvdpwvram 0x1800
	
	ld b,0
	; xor a / out / djnz = 28 T, sotto il minimo di 29 richiesto dal VDP
	;1:	xor a
	;	out (VDP),a
	;	djnz 1b
1:	xor a		;  4 T
	out (VDP),a	; 11 T
	dec	b		;  4 T
	jp	nz,1b	; 10 T	-> 29 T esatti
    enaint

	ld	hl,0
	ld (bannertimer),hl			; reset bonus
	ld	(xmap),hl
	ld	bc,xship_rel
	add hl,bc
	ld	(xship),hl

	ld	a,(cur_level)
	ld	l,a
	ld	h,0
	add hl,hl
	ld	bc,meta_levels
	add	hl,bc
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	de,level_buffer
	call	mom_depack_rom
	
	ld	a,(cur_level)
	and	a
	ret	z					; no runways in warp level
	ld	ix,runways
	ld	b,a
	ld	de,obj_data
2:	add	ix,de
	djnz	2b
	ld (curr_runway),ix
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
test_pause:
	; out (0x80),a
	; ex (sp),hl
	; ex (sp),hl
	; in a,(0xfc)
	; ld e,a
	; in a,(0xff)
	; and e
	; and 0x0f
	; xor 0x09		; Keypad asterisk
	
	; jr	nz,1f
	; scf
; 1:	ld	a,(halt_gamef1)
	; rla
	; ld	(halt_gamef1),a
	; and 3
	; cp  2
	; ret nz			; no pause 
	
	; ld	a,16		; pause
	; call AFXPLAY
	
	
	; ld	a,(halt_game)
	; xor 255
	; ld	(halt_game),a
	; jr	z,stop_music
; start_music
	; xor	a
	; ld	(music_flag),a
	; ret
; stop_music
	; dec	a			;ld	a,0xff
	; ld	(music_flag),a
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_set_godmode:
	disint	

	call joy0_read
	and  $11		; Test Fire1 + Up

		
	jr	nz,1f
	ld	a,-1
	ld	(enable_cheat),a
	ld	a,17				; secrete sound
	call AFXPLAY	

1:	enaint	

	call sfx_waitsfx

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ms_col_win:
	include "ms_demo_frm_coll_wind.asm"
ms_bllts_col_win:
	include "ms_bllts_frm_coll_wind.asm"

	include "ms_crtl.asm"

	; code @  0x7000
	; db 0

	include "mc_collide.asm"
	include "ms_bllts.asm"
	include "put_ms_sprt.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "collision_tst.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "mothership_sequence.asm" 
	include "plot_enemies.asm"  
	include "runways.asm"  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	IF VIDEOPLAYER
	include "endanim/vidoplayer.asm"
	ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "scorebar_pos.asm"
	include "scorebar.asm"	
    ;include pagesupport.asm
	include "sprtinit.asm"
	;include PT3-ROM.ASM
	;include AYFX-ROM.ASM
	include "enemies.asm"
	;include SCCaudio.asm
	include "sn7audio.asm"
	include "artvoice.asm"
	;include wrtpsg_x.asm
	include "show_instructions.asm"
	include "attract_mode.asm"	

	include "PSGLib.asm"
	


loading_pat:
	incbin "LOADING_.patt.pck"
loading_nam:
	incbin "LOADING_.nam.pck"
loading_col:
	incbin "LOADING_.color.pck"
	
	
loading_screen:
	ld	hl, loading_pat
	ld  de, 0x0000
	call BitBuster_UnpackVRAM

	ld	hl, loading_nam
	ld  de, 0x1800
	call BitBuster_UnpackVRAM

	ld	hl, loading_col
	ld  de, 0x2000
	call BitBuster_UnpackVRAM

	ret

	
	IF PAUSEENABLED

;===============================================
NMI_VECTOR:
;===============================================
	push af
	; ld a, (ingame)
	; or a
	; jp z, exit_nmi

	ld a, (PAUSE_COUNTER)
	cp $10
	jr c, 1f
	xor a
	ld (PAUSE_COUNTER), a
	ld a, (PAUSE_FLAG)
	and a
	jr z, 2f
	xor a
	ld (PAUSE_FLAG), a
1:
	ld a, 1
	ld (PAUSE_CHANGED), a
	
;	call set_level_name

	pop af
	retn
2:
	cpl
	ld (PAUSE_FLAG), a
	call PSGSilenceChannels

	ld a, 1
	ld (PAUSE_CHANGED), a
;	call draw_paused
;	call set_level_name

	; ld a, $9F
	; out (Port_PSG), a
	; ld a, $BF
	; out (Port_PSG), a
	; ld a, $DF
	; out (Port_PSG), a
	; ld a, $FF
	; out (Port_PSG), a
exit_nmi:
	pop af
	retn
	
	ENDIF	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "victory.asm"
	
	
endpage7:
	ds $7fbe-$,$ff		
	dw 1


























;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; pad previous bank to its full 0x4000 size (see note above)
	PAD_TO 0x8000

	SLOT 2 : PAGE 2 : BANK_ORG 0x8000		; to access at this page use  LD A,($FFF9)
filler_page2:
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "leveldata.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

defaultpage2:
	db $55, $AA
endpage1:
	ds $bfbe-$,$ff
	dw 2

















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; pad previous bank to its full 0x4000 size (see note above)
	PAD_TO 0xC000

	SLOT 2 : PAGE 3 : BANK_ORG 0x8000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
filler_page3:
	nop

splash_shps:
	incbin "MANTA_shps.miz"
splash_clrs:
	incbin "MANTA_clrs.miz"
	
vsplash_shps:
	incbin "ENDING2_chr.miz"
vsplash_clrs:
	incbin "ENDING2_clr.miz"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "tileinit.asm"
	include "clr_map.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
victory_screen:
	ld	hl,level_buffer
	ld	de,level_buffer+1
	ld	bc,256*3*8
	ld	(hl),0
	ldir

	ld	hl,vsplash_shps
 	ld	de,level_buffer+64
	call	mom_depack_rom
	_setvdpwvram (0x0000)
	ld	hl,level_buffer
	.3	call	write_256

	ld	hl,vsplash_clrs
	ld	de,level_buffer+64
	call	mom_depack_rom
	_setvdpwvram (0x2000)
	ld	hl,level_buffer
	.3	call	write_256

	_setvdpwvram 0x1800
	xor	a
	ld	b,2
1:	out	(VDP),a
	inc	a
	jr	nz,1b
	djnz	1b
	ret

show_manta:
    disint
	call	disscr
 
	ld	hl,splash_shps
 	ld	de,level_buffer
	call	mom_depack_rom
	_setvdpwvram 0x0000
	ld	hl,level_buffer
	.3	call	write_256

	ld	hl,splash_clrs
	ld	de,level_buffer
	call	mom_depack_rom
	_setvdpwvram 0x2000
	ld	hl,level_buffer
	.3	call	write_256

	_setvdpwvram 0x1800
	xor	a
	ld	b,3
1:	out	(VDP),a
	inc	a
	jr	nz,1b
	djnz	1b
	call	enascr
    enaint
	
	ret

; mus_intro:
	; db 00,00,01,01,09,03,01,03,13,00,00,00,00,00,00,00
	; incbin UR_TITLE.MIZ
; mus_red:
	; db 00,06,00,06,13,13,13,13,13,00,00,06,00,00,00,00
	; incbin UR_RED.MIZ
; mus_green:
	; db 00,05,14,06,05,05,05,05,05,00,00,00,00,00,00,00
	; incbin UR_GREEN.MIZ
; mus_blue:
	; db 00,15,14,12,15,15,15,15,15,00,00,00,06,12,08,00
	; incbin UR_BLUE.MIZ



endpage2: 
	ds $bfbe-$,$ff
	dw 3























;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; pad previous bank to its full 0x4000 size (see note above)
	PAD_TO 0xC000

	SLOT 2 : PAGE 4 : BANK_ORG 0x8000		; to access at this page use  LD A,($FFFB)
filler_page4:

_rom_tileset:
	incbin "options/uridium_font2.bin"
	;incbin rom_tileset.bin

	include "font.asm"
	db "FONT2",0

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "directions.asm"
_enemy3:	
	include "enemy3.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	

	incbin "bonus.bin"
bonus_sign:
	incbin "bmp105/bonus.mgb"
	
	
	
_alarm:
	incbin "Enemies.wav_sn76489.bin"
_alarm0:
	incbin "alarm.wav_sn76489.bin"
_alarm1:	
	incbin "watch_out.wav_sn76489.bin"
_alarm2:	
	incbin "shoot_up.wav_sn76489.bin"
_alarm3:	
	incbin "watch_your_back.wav_sn76489.bin"
	
_gameover:
	incbin "Game_over.wav_sn76489.bin"

_defeated:
	incbin "Bombs_in_place.wav_sn76489.bin"
	
_no_god:
	incbin "No_not_now.wav_sn76489.bin"
_syren:
	incbin "syren.wav_sn76489.bin"
_land_now:
	incbin "land_now.wav_sn76489.bin"
_explosion:
	incbin "explosion.wav_sn76489.bin"
;_explosion2:	
;	incbin "Exploding-Sound_Explorer-68256487.wav_sn76489.bin"
	
_levelcompleted:	
	; incbin "menu_levelup.wav_sn76489.bin"
	incbin "level_completed.wav_sn76489.bin"



	
endpage3:	
	ds $bfbe-$,$ff
    dw 4     		; This gives info to interruption routine to restore slot
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	; pad previous bank to its full 0x4000 size (see note above)
	PAD_TO 0xC000

	SLOT 2 : PAGE 5 : BANK_ORG 0x8000		; to access at this page use  LD A,($FFFC)
filler_page5:
	nop

	IF SHOWMANTA105
manta_wins:			; image with 105 colors
	incbin "bmp105/merge2.bin"

youhavewon:			; heading 
	incbin "bmp105/youhavewon.mgb"

show_manta_wins:

	call	disscr
	_setvdpwvram (0x2800)
	ld hl,manta_wins
	call	write_256
	call	write_256
	_setvdpwvram (0x0000)
	call	write_256
	
	_setvdpwvram (0x0800)
	call	write_256
	call	write_256
	_setvdpwvram (0x2000)
	call	write_256
		
	_setvdpwvram (0x1800)
	ld 	a,252				; blank tile
	ld	b,0
1:	out	(VDP),a
	djnz 1b

	call	enascr
	enaint


	ld hl,_explosion
	call .explosion
	
	ld hl,_explosion
	call .explosion
	
	ld hl,_explosion
	call .explosion


	; ld hl,_explosion
	; call .explosion
	
	; ld hl,_explosion
	; call .explosion
	
	; ld hl,_explosion
	; call .explosion

	
	disint
	_setVdp 3,0xFF	;	colours at 0x2000	(regular mode for colours)
	_setVdp 4,0x03	;	patterns at 0x0000	(regular: used 0x0800 0x1000)
	enaint	
	ret
	
.explosion
	ld (_vocadr),hl
	ld hl,0
	ld (bannertimer),hl

1:	disint
	ld	hl,youhavewon
	call setbanner
	enaint	
	
	call .twoframes

	ld hl,(bannertimer)
	inc hl
	ld (bannertimer),hl
	
	ld 	hl,(_vocadr)
	ld a,l
	or h
	jp nz,1b
	ret
	
.twoframes:
	halt
	call disp_page1
	_setvdpwvram (0x1900)
	ld hl,manta_wins+6*2048+512
	call setbanner.out256
	call setbanner.out256
	
	halt
	call disp_page0
	_setvdpwvram (0x1900)
	ld hl,manta_wins+6*2048+0
	call setbanner.out256
	call setbanner.out256
	ret
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
disp_page1:			; page 1 active
	_setVdp 3,0x9F	;	colours at 0x2000	(hybrid)
	_setVdp 4,0x03	;	patterns at 0x0000	(regular: used 0x0800 0x1000)
	ret
disp_page0:			; page 0 active
	_setVdp 3,0x1F	;	colours at 0x0000	(hybrid)
	_setVdp 4,0x07	;	patterns at 0x2000	(regular: used 0x2800 0x3000)
	ret

	ENDIF




endpage4:
	ds $bfbe-$,$ff
    dw 5     		; This gives info to interruption routine to restore slot
	











	





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; pad previous bank to its full 0x4000 size (see note above)
	PAD_TO 0xC000

	SLOT 2 : PAGE 6 : BANK_ORG 0x8000  ; to access at this page use  LD A,($FFFE)
filler_page8:
	nop

mus_bank:

mus_intro:
	db 00,00,01,01,09,03,01,03,13,00,00,00,00,00,00,00
	incbin "UR_TITLE.PSG"


normal_sprites_spt:
	incbin "uridium_rev6b.miz"		; incbin uridium_rev6.miz
ennanched_sprites_spt_3c:
	incbin  "uridium_rev8.miz"		; with the extra sprites ; incbin  uridium_rev7.miz



ending_pat:
	incbin "ENDINGPI.til.pck"
ending_nam:
	incbin "ENDINGPI.nam.pck"
ending_col:
	incbin "ENDINGPI.col.pck"
	
	
ending_screen:
	ld	hl, ending_pat
	ld  de, 0x0000
	call BitBuster_UnpackVRAM

	ld	hl, ending_nam
	ld  de, 0x1800
	call BitBuster_UnpackVRAM

	ld	hl, ending_col
	ld  de, 0x2000
	call BitBuster_UnpackVRAM
	ret
	

;mus_intro:
	; db 00,00,01,01,09,03,01,03,13,00,00,00,00,00,00,00
	; incbin UR_TITLE.BIN


; mus_red:
	; db 00,06,00,06,13,13,13,13,13,00,00,06,00,00,00,00
	; incbin UR_RED.BIN

; mus_green:
	; db 00,05,14,06,05,05,05,05,05,00,00,00,00,00,00,00
	; incbin UR_GREEN.BIN

; mus_blue:
	; db 00,15,14,12,15,15,15,15,15,00,00,00,06,12,08,00
	; incbin UR_BLUE.BIN



endpage8:
	ds $bfbe-$,$ff
	dw 6





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; pad previous bank to its full 0x4000 size (see note above)
	PAD_TO 0xC000

	SLOT 2 : PAGE 7 : BANK_ORG 0x8000  ; to access at this page use  LD A,($FFFE)
filler_page9:
	nop

mus_end:
	db 00,05,15,15,06,00,00,15,00,00,00,00,00,00,00,00
	incbin "UR_ENDING.PSG"


endpage9:
	ds $bfbe-$,$ff
	dw 7

	; pad the last bank to its full 0x4000 size (see note above)
	PAD_TO 0xC000











	IF VIDEOPLAYER

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	code	page 8	; to access at this page use  LD A,($FFFD)
filler_page6:
	nop

; normal_sprites_spt:
	; incbin uridium_rev6b.miz		; incbin uridium_rev6.miz
; ennanched_sprites_spt_3c:
	; incbin  uridium_rev8.miz		; with the extra sprites ; incbin  uridium_rev7.miz

chr:
	include "endanim/tstchr.asm"
clr:
	include "endanim/tstclr.asm"
	
	
endpage5:
	ds $bfbe-$,$ff
	dw 8
	



	code page 9  ; to access at this page use  LD A,($FFFE)
filler_page7:
	nop

	include "endanim/frames.asm"
	
endpage6:
	ds $bfbe-$,$ff
	dw 9


	ENDIF	







	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ram data
    
	
;MSX_O_Mizer_buf:	equ	0x7e00	; ds	328+26 aligned at 0x100

;	map 0x4000

	
;MSX_O_Mizer_buf:	equ	0xFE00	; ds	328+26 aligned at 0x100
MSX_O_Mizer_buf:	equ	0xFB00	; ds	328+26 aligned at 0x100

MAPPTR DEFL 0xC000
unpack_buffer: EQU MAPPTR
MAPPTR DEFL MAPPTR+(0)
meta_pnt_table_u: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1024)
meta_pnt_table_d: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1024)
miz_buffer: EQU MAPPTR
MAPPTR DEFL MAPPTR+(3*1024)

level_buffer: EQU MAPPTR
MAPPTR DEFL MAPPTR+(LvlWidth*16+32)

toshiba_switch: EQU MAPPTR ; Toshiba
MAPPTR DEFL MAPPTR+(1)
game_speed: EQU MAPPTR ; game speed 1,2,3,4
MAPPTR DEFL MAPPTR+(1)
;victory:			#	1		
visible_sprts: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
;ingame:				#	1
aniframe: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
old_aniframe: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)

ms_state: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
anispeed: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
anispeedcnt: EQU MAPPTR ; used to slow down the manta animation
MAPPTR DEFL MAPPTR+(1)

PT3_SETUP: EQU MAPPTR ;set bit0 to 1, if you want to play without looping
MAPPTR DEFL MAPPTR+(1)
					        ;bit7 is set each time, when loop point is passed
PT3_SFXBANK: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
PT3_MODBANK: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
PT3_MODADDR: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)

PT3_CrPsPtr: EQU MAPPTR ; Patter# = CrPsPtr-song_buffer-101;
MAPPTR DEFL MAPPTR+(2)
PT3_SAMPTRS: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_OrnPtrs: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_PDSP: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_CSP: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_PSP: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_PrNote: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
PT3_PrSlide: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_AdInPtA: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_AdInPtB: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_AdInPtC: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_LPosPtr: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_PatsPtr: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
PT3_Delay: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
PT3_AddToEn: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
PT3_Env_Del: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
PT3_ESldAdd: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)

VARS: EQU MAPPTR
MAPPTR DEFL MAPPTR+(0)
ChanA: EQU MAPPTR ;CHNPRM_Size
MAPPTR DEFL MAPPTR+(30)
ChanB: EQU MAPPTR ;CHNPRM_Size
MAPPTR DEFL MAPPTR+(30)
ChanC: EQU MAPPTR ;CHNPRM_Size
MAPPTR DEFL MAPPTR+(30)

;GlobalVars
DelyCnt: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
CurESld: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
CurEDel: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)

Ns_Base_AddToNs: EQU MAPPTR
MAPPTR DEFL MAPPTR+(0)
Ns_Base: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
AddToNs: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)

;AYREGS:     		#	0
VT_: EQU MAPPTR
MAPPTR DEFL MAPPTR+(14)
; EnvBase:			#	2
; VAR0END:			#	240

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper variables from PT3 mobule


_psg_vol_fix: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
_sfx_vol_fix: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)

fade_psg_vol_fix: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)

_psg_vol_balance: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)

; IF PAUSEENABLED	
; PAUSE_COUNTER:		#	1
; PAUSE_FLAG:			#	1
; ENDIF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wchA:				#	1	; wave on channel A
; wchB:				#	1	; wave on channel B
; wchC:				#	1	; wave on channel C
; pt3 samples previously detected (times 2)
; OSmplA          	#	1
; OSmplB          	#	1
; OSmplC          	#	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

reverse_sat: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)

ayFX_PRIORITY: EQU MAPPTR ; Current ayFX stream priority
MAPPTR DEFL MAPPTR+(1)

		; --- THIS FILE MUST BE COMPILED IN RAM ---

ayFX_PLAYING: EQU MAPPTR ; There's an ayFX stream to be played?
MAPPTR DEFL MAPPTR+(1)
ayFX_CURRENT: EQU MAPPTR ; Current ayFX stream playing
MAPPTR DEFL MAPPTR+(1)
ayFX_POINTER: EQU MAPPTR ; Pointer to the current ayFX stream
MAPPTR DEFL MAPPTR+(2)
ayFX_TONE: EQU MAPPTR ; Current tone of the ayFX stream
MAPPTR DEFL MAPPTR+(2)
ayFX_NOISE: EQU MAPPTR ; Current noise of the ayFX stream
MAPPTR DEFL MAPPTR+(1)
ayFX_VOLUME: EQU MAPPTR ; Current volume of the ayFX stream
MAPPTR DEFL MAPPTR+(1)
ayFX_CHANNEL: EQU MAPPTR ; PSG channel to play the ayFX stream
MAPPTR DEFL MAPPTR+(1)
ayFX_VT: EQU MAPPTR ; ayFX relative volume table pointer
MAPPTR DEFL MAPPTR+(2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

vsf: EQU MAPPTR ; 0 if 50Hz, !0 if 60Hz
MAPPTR DEFL MAPPTR+(1)
cnt: EQU MAPPTR ; counter to compensate NTSC machines
MAPPTR DEFL MAPPTR+(1)

randSeed: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)

;_vdpReg				#	8
;JIFFY				# 	2
;nmimode				# 	2


assault_wave_timer: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
wave_count: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
landing_permission: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
bullet_rate: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
dxmap: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
xmap: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
yship: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
xship: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
zship: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
cur_level: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
next_level: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
sprite_3c: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
clr_table: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
joystick: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
old_joystick: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
chang_joystick: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
menu_item: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
already_dead: EQU MAPPTR ; set after you die, reset at level start 
MAPPTR DEFL MAPPTR+(1)
music_off: EQU MAPPTR ; if set do not play music
MAPPTR DEFL MAPPTR+(1)
voice_off: EQU MAPPTR ; if set do not play voice
MAPPTR DEFL MAPPTR+(1)
god_mode: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
enable_cheat: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
halt_game: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
menu_level: EQU MAPPTR
MAPPTR DEFL MAPPTR+(0)
halt_gamef1: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
lives: EQU MAPPTR
MAPPTR DEFL MAPPTR+(3)
dummy_: EQU MAPPTR
MAPPTR DEFL MAPPTR+(4)
score: EQU MAPPTR
MAPPTR DEFL MAPPTR+(7)
score_bin: EQU MAPPTR
MAPPTR DEFL MAPPTR+(4)
lives_bin: EQU MAPPTR ; BCD !!!
MAPPTR DEFL MAPPTR+(1)

start_intro_mus: EQU MAPPTR ; if set start intro music
MAPPTR DEFL MAPPTR+(1)
toggle_scc: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
save_SCC: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
curr_runway: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
goal_supp: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
shieldlevel: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)


PSGMusicStatus: EQU MAPPTR ; are we playing a background music?
MAPPTR DEFL MAPPTR+(1)
PSGMusicStart: EQU MAPPTR ; the pointer to the beginning of music
MAPPTR DEFL MAPPTR+(2)
PSGMusicPointer: EQU MAPPTR ; the pointer to the current
MAPPTR DEFL MAPPTR+(2)
PSGMusicLoopPoint: EQU MAPPTR ; the pointer to the loop begin
MAPPTR DEFL MAPPTR+(2)
PSGMusicSkipFrames: EQU MAPPTR ; the frames we need to skip
MAPPTR DEFL MAPPTR+(1)
PSGLoopFlag: EQU MAPPTR ; the tune should loop forever or not (flag)
MAPPTR DEFL MAPPTR+(1)
PSGLoopCounter: EQU MAPPTR ; how many times the tune should loop
MAPPTR DEFL MAPPTR+(1)
PSGMusicLastLatch: EQU MAPPTR ; the last PSG music latch
MAPPTR DEFL MAPPTR+(1)

; decompression vars
PSGMusicSubstringLen: EQU MAPPTR ; lenght of the substring we are playing
MAPPTR DEFL MAPPTR+(1)
PSGMusicSubstringRetAddr: EQU MAPPTR ; return to this address when substring is over
MAPPTR DEFL MAPPTR+(2)

; command buffers
PSGChan0Volume: EQU MAPPTR ; the volume for channel 0
MAPPTR DEFL MAPPTR+(1)
PSGChan1Volume: EQU MAPPTR ; the volume for channel 1
MAPPTR DEFL MAPPTR+(1)
PSGChan2Volume: EQU MAPPTR ; the volume for channel 2
MAPPTR DEFL MAPPTR+(1)
PSGChan3Volume: EQU MAPPTR ; the volume for channel 3
MAPPTR DEFL MAPPTR+(1)
PSGChan2LowTone: EQU MAPPTR ; the low tone bits for channels 2
MAPPTR DEFL MAPPTR+(1)
PSGChan3LowTone: EQU MAPPTR ; the low tone bits for channels 3
MAPPTR DEFL MAPPTR+(1)
PSGChan2HighTone: EQU MAPPTR ; the high tone bits for channel 2
MAPPTR DEFL MAPPTR+(1)

PSGMusicVolumeAttenuation: EQU MAPPTR ; the volume attenuation applied to the tune (0-15)
MAPPTR DEFL MAPPTR+(1)

; ******* SFX *************

; flags for channels 2-3 access
PSGChannel2SFX: EQU MAPPTR ; !0 means channel 2 is allocated to SFX
MAPPTR DEFL MAPPTR+(1)
PSGChannel3SFX: EQU MAPPTR ; !0 means channel 3 is allocated to SFX
MAPPTR DEFL MAPPTR+(1)

; command buffers for SFX
PSGSFXChan2Volume: EQU MAPPTR ; the volume for channel 2
MAPPTR DEFL MAPPTR+(1)
PSGSFXChan3Volume: EQU MAPPTR ; the volume for channel 3
MAPPTR DEFL MAPPTR+(1)

; fundamental vars for SFX
PSGSFXStatus: EQU MAPPTR ; are we playing a SFX?
MAPPTR DEFL MAPPTR+(1)
PSGSFXStart: EQU MAPPTR ; the pointer to the beginning of SFX
MAPPTR DEFL MAPPTR+(2)
PSGSFXPointer: EQU MAPPTR ; the pointer to the current address
MAPPTR DEFL MAPPTR+(2)
PSGSFXLoopPoint: EQU MAPPTR ; the pointer to the loop begin
MAPPTR DEFL MAPPTR+(2)
PSGSFXSkipFrames: EQU MAPPTR ; the frames we need to skip
MAPPTR DEFL MAPPTR+(1)
PSGSFXLoopFlag: EQU MAPPTR ; the SFX should loop or not (flag)
MAPPTR DEFL MAPPTR+(1)

; decompression vars for SFX
PSGSFXSubstringLen: EQU MAPPTR ; lenght of the substring we are playing
MAPPTR DEFL MAPPTR+(1)
PSGSFXSubstringRetAddr: EQU MAPPTR ; return to this address when substring is over
MAPPTR DEFL MAPPTR+(2)


  
  
	struct enemy_data
fy				db	0             ;fx,fy fractional part
y				db	0
fx				db	0
x				dw	0
xoff			db	0
yoff			db	0
xsize			db	0
ysize			db	0
status			db	0	; B7 == DWN/UP | B6 == RIGHT/LEFT | B0 == Inactive/Active
cntr			db	0
kind			db	0
frame			db	0
color			db	0
speed			dw	0
dxx				dw	0
dyy				dw	0
goaly			dw	0
angle			dw	0
	ends

level_goal: EQU MAPPTR ; number of ground targhets to be destroied in the current level	
MAPPTR DEFL MAPPTR+(1)
nturrets: EQU MAPPTR ; number of remaining turrets
MAPPTR DEFL MAPPTR+(1)
bannertimer: EQU MAPPTR ; number of tics to change the banner
MAPPTR DEFL MAPPTR+(2)
backcolor: EQU MAPPTR ; background color
MAPPTR DEFL MAPPTR+(1)
KBD_PRESENT: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
;VDPFREQ:			#   1
INTVECTOR: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
; [max_enem]			enemy_data
; [max_bullets]			enemy_data
; [max_enem_bullets]	enemy_data

enemies: EQU MAPPTR
MAPPTR DEFL MAPPTR+(enemy_data*max_enem)
ms_bullets: EQU MAPPTR
MAPPTR DEFL MAPPTR+(enemy_data*max_bullets)
enem_bullets: EQU MAPPTR
MAPPTR DEFL MAPPTR+(enemy_data*max_enem_bullets)
ram_sat: EQU MAPPTR
MAPPTR DEFL MAPPTR+(128)
_vocadr: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
music_flag: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)

turret_type: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)

_times: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
_pointer: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
_cframe: EQU MAPPTR
MAPPTR DEFL MAPPTR+(2)
buffer: EQU MAPPTR
MAPPTR DEFL MAPPTR+(768)

last_ram_byte: EQU MAPPTR
MAPPTR DEFL MAPPTR+(1)
	; end of map block (was endmap)
	

