	db "[PSG_BANK_STA]"

PSG_LATCH	equ 0x80
PSG_VOLUME	equ 0x90
PSG_DATA	equ 0x40		; USED BY PSGLib
PSG_CHAN0	equ 0x00
PSG_CHAN1	equ 0x20
PSG_CHAN2	equ 0x40
PSG_CHAN3	equ 0x60



;SFX_FIRE_CHN:		equ 2
;SFX_CHANNEL0:       equ SFX_CHANNEL2 ;$04

SFX_FIRE_CHN:		equ 1
SFX_CHANNEL0:       equ $04

SFX_CHANNEL1:       equ $08


sfx_init:
	ld  a, PSG_CHAN0 + 0xF + PSG_VOLUME 
	out (0x7F),a
	ld  a, PSG_CHAN1 + 0xF + PSG_VOLUME 
	out (0x7F),a
	ld  a, PSG_CHAN2 + 0xF + PSG_VOLUME 
	out (0x7F),a
	ld  a, PSG_CHAN3 + 0xF + PSG_VOLUME 
	out (0x7F),a
	
	ld  a, PSG_CHAN0 + 0 + PSG_LATCH
	out (0x7F),a
	ld  a, PSG_CHAN0 + 0
	out (0x7F),a

	ld  a, PSG_CHAN1 + 0 + PSG_LATCH
	out (0x7F),a
	ld  a, PSG_CHAN1 + 0
	out (0x7F),a

	ld  a, PSG_CHAN2 + 0 + PSG_LATCH
	out (0x7F),a
	ld  a, PSG_CHAN2 + 0
	out (0x7F),a

	ld  a, PSG_CHAN3 + 4 + PSG_LATCH
	out (0x7F),a
	ret

sfx_waitsfx:
	ld a,(PSGSFXStatus)                         ; if it's already stopped, leave
	cp PSG_PLAYING
	jp z, sfx_waitsfx
	ret

sfx_waitmusic:
	ld a,(PSGMusicStatus)                        ; if it's already stopped, leave
	cp PSG_PLAYING
	jp z, sfx_waitmusic
	ret

  
sfx_play:
	ld  c, a
	ld	hl,(_vocadr)
	ld  a, l
	or  h
	ret nz
	
	;call PSGSFXStop
	ld a, c
	
	
	ld hl, sfx_bank

	add a, a
	add a, a
	
	ld e, a
	ld d, 0
	add hl, de
	
	ld c, (hl)		; Get SFX Channel Config
	inc hl
	inc hl

	ld e, (hl)		; Get SFX sequence address
	inc hl
	ld d, (hl)
	ex de, hl
	
	
	ld a, c
	cp SFX_CHANNEL0
	jp z, sfx_mus
	call PSGSFXPlay
	ret
	
sfx_mus:	
	ld e, $$sfx_bank
	call PT3_INIT
	;call PSGPlayNoRepeat
	ret




;------------------------
	macro _psg_end

	_psg_vol 2, 0
	_psg_vol 3, 0
	_psg_eof 0
	db 0x00

	endm

;------------------------
	macro _psg_eof add_frames

	db 0x38 + (add_frames & 0x7)

	endm

;------------------------
	macro _psg_noise_verylow

	_psg_vol 2, 0
	_psg_vol 3, 0
	db 0xE7
	
	_psg_eof 0

	endm
;------------------------
	macro _psg_noise_low

	_psg_vol 2, 0
	_psg_vol 3, 0
	db 0xE5

	_psg_eof 0

	endm
	
;------------------------
	macro _psg_noise_medium 

	_psg_vol 2, 0
	_psg_vol 3, 0
	db 0xE5

	_psg_eof 0

	endm
	
;------------------------
	macro _psg_noise_high

	_psg_vol 2, 0
	_psg_vol 3, 0
	db 0xE4

	_psg_eof 0

	endm	
	
;------------------------
	macro _psg_pulse

	_psg_vol 2, 0
	_psg_vol 3, 0
	db 0xE3

	_psg_eof 0

	endm		

;------------------------
	macro _psg_pulseN

	_psg_vol 2, 0
	_psg_vol 3, 0
	db 0xE2

	_psg_eof 0

	endm		

;------------------------
	macro _psg_vol chn, vol

	db PSG_VOLUME + ((chn & 3) * 32) + (15 - (vol & 15))

	endm

;------------------------
	macro _psg_frq chn, freq

	db PSG_LATCH + ((chn & 3) * 32) + ((freq & 0x000F)     )
	db PSG_DATA                     + ((freq & 0x03F0) / 16)

	endm
	
	macro _psg_cell chn, freq, vv

	_psg_frq chn, freq
	_psg_vol chn, vv
	_psg_eof 0x00

	endm

;------------------------
	macro _psg_cell_vol chn, vv

	_psg_vol chn, vv
	_psg_eof 0x00
	_psg_vol 3, 0

	endm	

;------------------------
	macro _psg_chans23 freq2, volchn2

	_psg_frq 2, freq2
	_psg_vol 2, ((volchn2*30)/32)
	_psg_vol 3, volchn2
	;db PSG_VOLUME + PSG_CHAN3 + (volnoise / 2)
	

	_psg_eof 0x00

	endm	
	


	
	macro _psg_chansP freq2, volchn3

	if (freq2 & 0xC00)
		_psg_frq 2, (freq2 & 0x3FF) - 0x400
	else
		_psg_frq 2, (freq2 - 0x400)
	endif
	
	_psg_vol 3, ((volchn3*30)/32)

	_psg_eof 0x00

	endm		
	
	macro _psg_chansPX freq2, volchn3

	_psg_frq 2, freq2
	_psg_vol 3, volchn3

	_psg_eof 0x00

	endm		
	
	
	

sfx_bank:	
	dw SFX_CHANNEL2,		sfx01_ms_fire							 ; 01
	dw SFX_CHANNEL2,		sfx02_wave_incoming                      ; 02
	dw SFX_CHANNELS2AND3,	sfx03_enemy_explode01                    ; 03
	dw SFX_CHANNELS2AND3,	sfx04_enemy_explode02                    ; 06
	dw SFX_CHANNELS2AND3,	sfx05_enemy_explode03                    ; 05
	dw SFX_CHANNELS2AND3,	sfx06_enemy_explode04                    ; 06
	dw SFX_CHANNELS2AND3,	sfx07_exit                               ; 07
	dw SFX_CHANNELS2AND3,	sfx08_start_level_sound                  ; 08
	dw SFX_CHANNEL2,		sfx09_enemy_shoot                        ; 09
	dw SFX_CHANNELS2AND3,	sfx10_ms_explosion                       ; 10
	dw SFX_CHANNEL0,		sfx11_ms_bullets_hit_solid_wall          ; 11		; ship fire 
	dw SFX_CHANNELS2AND3,	sfx12_destroy_small_ground_item          ; 12
	dw SFX_CHANNELS2AND3,	sfx13_destroy_large_ground_item          ; 13
	dw SFX_CHANNELS2AND3,	sfx14_landing                            ; 14
	dw SFX_CHANNEL2,		sfx15_landing_alert                      ; 15
	dw SFX_CHANNELS2AND3,	sfx16_take_off                           ; 16
	dw SFX_CHANNEL2,		sfx17_pause1                             ; 17
	dw SFX_CHANNEL2,		sfx18_pause2                             ; 18
	dw SFX_CHANNEL2,		sfx19_live_up                            ; 19
	dw SFX_CHANNELS2AND3,	sfx20_game_over                          ; 20
	dw SFX_CHANNELS2AND3,	sfx21_warping                            ; 21
	
	
	; sound effect definitions (sfx00..sfx21): not distributed, see README
	include "sfx_data.asm"
