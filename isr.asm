
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Interrupt service routine
;


	
	; code @  0x0008
	; push hl
	; ld hl,nmimode
	; set 0,(hl)
	; pop hl
	; ret

	; code @  0x0010
	; push hl
	; ld hl,nmimode
	; res 0,(hl)
	; nop
	; bit 1,(hl)
	; pop hl
	; ret z
	; push af
	; push hl
	; ld hl,nmimode
	; res 1,(hl)
	; jp isr2



isr_simple:
	pop	   hl

	push   af         
	push   hl

	in		a, (VDP+1)		; acknowledge VDP

	ld		hl, JIFFY
	inc		(hl)

	pop    hl
	pop    af         
	
	ei						; reenable INT
	ret						; ret is enough for IM 1






isr:
	push   hl
	ld     hl, (INTVECTOR)
	jp	   (hl)




isr_game:
	pop	   hl

	push   af         
	push   hl


	; ld hl,nmimode
	; bit 0,(hl)
	; jr z,isr2
	
	; set 1,(hl)
	; pop hl
	; pop af
	
	; ei
	; ret
	
	
; isr2:    


	push   de         
	push   bc         
	push   iy         
	push   ix         
	

	
	;_PROFsetVdp 7,0x04
	
	ld	a,(ingame)
	and	a
	jp	z,Music_only

	_setVdp 5,0x37		;	SAT at 0x1b80
	_setVdp 6,0x03		;	SPT at 0x1800	(used from 0x1C00 to 0x1FFF	only 32 sprites 16x16)
	

	call 	_sat_update
	call	_plot_spt
	_PROFsetVdp 7,0x00
		
	ld	a,(toshiba_switch)		; Toshiba
	and	a
	jr	nz,.compatibilty
	
	ld	a,(xmap)				; TMS
	and 2
	jp	z,.other_page
	
	_setVdp 3,0x1F	;	colours at 0x0000	(hybrid)
	_setVdp 4,0x07	;	patterns at 0x2000	(regular: used 0x2800 0x3000)
	
	jp	.this_page
	
.other_page:

	_setVdp 3,0x9F	;	colours at 0x2000	(hybrid)
	_setVdp 4,0x03	;	patterns at 0x0000	(regular: used 0x0800 0x1000)
	
.this_page:
	
	_setvdpwvram 0x1900
	call	_plot_pnt
	jp	1f
	
.compatibilty:
	_setvdpwvram 0x1900
	call	_plot_pnt_toshiba
1:
	call	_plot_strs




	_PROFsetVdp 7,0x0A
	call	test_pause
	
	_PROFsetVdp 7,0x07
	
split_screen:	
	
1:	in	a,(VDP+1)
	.2	ex 	(sp),hl
	and 0x5F
	cp	0x5C		; plane 28 =0x1C
	jp	c,1b		; if SR<28 wait
	
	_PROFsetVdp 7,0x0C
	
1:	in	a,(VDP+1)
	.2	ex 	(sp),hl
	and 0x5F
	cp	0x5D		; plane 29 =0x1D
	jp	c,1b		; if SR<29 wait


	.2	ex 	(sp),hl

	_PROFsetVdp 7,0x07
	
; 1:	in	a,(VDP+1)
; [2]	ex 	(sp),hl
	; and 0x40
	; jp	nz,1b		; wait for line 63
	
	; _setVdp 5,0x30	;	SAT at 0x1800	dummy SAT
	_setVdp 5,0x3F	;	SAT at 0x1F80	dummy SAT
	_setVdp 6,0x07	;	SPT at 0x3800	(64 sprites 16x16)
	_setVdp 5,0x36	;	SAT at 0x1b00	actual SAT
	
	_setVdp 7,(backcolor)	



	IF PAUSEENABLED

	ld a, (PAUSE_COUNTER)
	inc a
	cp $F0
	jr nc, 1f
	ld a, $F0
1:
	ld (PAUSE_COUNTER), a
	
	ld a, (PAUSE_FLAG)
	or a
	jp	nz, Paused
	
	ENDIF	


	call	PT3_ROUT	; Write values on PSG registers

	IF VOICESENABLED
	_PROFsetVdp 7,0x09
	call	inner_voice_code												; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	ENDIF
	
	
	; _setvdpwvram (0x1800+0x74)
	; ld a,b			; restore original value
	; out (VDP),a
	
	_PROFsetVdp 7,0x08
	call 	inner_audio_code

	_PROFsetVdp 7,(backcolor)

	ld	hl,JIFFY
	inc	(hl)			; 8 bit JIFFY

	pop    ix         
	pop    iy         
	pop    bc         
	pop    de
	
	pop    hl
	pop    af         
	
	ei
	ret
	

	IF PAUSEENABLED
	
Paused:
	in	a,(VDP+1)		; enable next isr


;	call 	set_level_name
	
;	call PSGSilenceChannels
;	ld	hl,JIFFY
;	inc	(hl)			; 8 bit JIFFY

	jp  isr_exit
	
	ENDIF
;;;;;;;;;;;;;;;;;;;;;;;;;;
; used in title screens	
	
Music_only:
	in	a,(VDP+1)		; enable next isr
	call	PT3_ROUT
	
	IF VOICESENABLED	
	call	inner_voice_code
	ENDIF

	call 	inner_audio_code

	ld	hl,JIFFY
	inc	(hl)			; 8 bit JIFFY

	; _setVdp 7,0x00
isr_exit:
	pop    ix         
	pop    iy         
	pop    bc         
	pop    de         
	pop    hl
	pop    af         
	
	ei
	ret


	IF VOICESENABLED	

inner_voice_code:
	ld      a,(vsf)
	and     a
	jp      nz,.PAL		; if PAL call at any interrupt
; .NTSC:
	ld      hl,cnt      ; if NTSC call 5 times out of 6
	dec     (hl)
	jp      nz,.PAL     ; skip one tic out of 6 when at 60hz
	ld      (hl),6      ; reset the tic counter
	ret					; skip_audio
.PAL:                   ; Calculates PSG values for next frame


	ld a,(0xbfbe)
	push af
	; ld a,(0xfff8+:_alarm)
	setpage2 $$_alarm
	
	call	_vocplay	; voice samples (only on SN768)
	pop af
	ld (PAGESWAP),a
	ret

	ENDIF

inner_audio_code:
	ld      a,(cnt)     ; 
	dec     a			; same as cp 1
	ret		z			; skip one tic out of 6 when at 60hz
.PAL:                   ; 
	
	call 	Audio_Internal_code
	
	ret

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT FAR STARFIELD
; input : none
;
_plot_strs:
	ld	hl,(xmap)	; x position in pixels
	srl h
	rr	l
	srl h
	rr	l
	srl h
	rr	l

	ld	de,level_buffer
	add hl,de

	ld	de,x_stars
	ld	ix,0x1900 + 0x4000
	.7	call onestar
onestar:
	; repeat 8
2:	ex de,hl
	ld   c,(hl)
	inc hl
	ld   b,(hl)
	inc hl
	ex de,hl
	add hl,bc
	add ix,bc

	ld	a,(hl)
	and a
	jr nz,1f

	ld	a,ixl
	out (VDP+1),a
	ld	a,ixh
	out (VDP+1),a

	ld	a,255
	out (VDP),a
1:
	ld	bc,2*LvlWidth-2*32
	add hl,bc
	; endrepeat

	ret
x_stars:
	defw	  28, 3-28+64,19-3+64,29-19+64,18-29+64, 5-18+64,14-5+64,26-14+64
	; defw	  1-18+32,  28-1+32,4-28+32,29- 4+32,20-29+32, 3-20+32, 8-3+32,26- 8+32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT PNT
; input : xmap
;
_plot_pnt_toshiba:
	ld	hl,(xmap)	; x position in pixels
	ld	a,l
	rrca
	and 0x2
	jp	1f

_plot_pnt:
	ld	hl,(xmap)	; x position in pixels
	ld	a,l
	rrca
	and 0x3
1:
	add a,meta_pnt_table_u/256
	ld	ixl,a

	srl h
	rr	l
	srl h
	rr	l
	srl h
	rr	l

	ld	de,level_buffer
	add hl,de

	ex	de,hl

	call	half_screen

	ld	a,ixl
	add a,meta_pnt_table_d/256-meta_pnt_table_u/256
	ld	ixl,a

half_screen:
	ld	c,VDP
	ld	ixh,8
1:
	ld	a,ixl
	ld	h,a
	ld	a,e
	add a,32
	jp	nc,.fast_loop

.slow_loop:
	DUP 32
	ld	a,(de)		; 7 clks
	ld	l,a			; 4
	outi			; 16
	inc de			; 6
					; = 33 clks
	EDUP

	ld	hl,LvlWidth-32
	add hl,de
	ex	de,hl

	dec ixh
	jp	nz,1b

	ret

.fast_loop:
	DUP 32
	ld	a,(de)		; 7 clks
	ld	l,a			; 4
	outi			; 16
	inc e			; 4
					; = 31 clks
	EDUP

	ld	hl,LvlWidth-32
	add hl,de
	ex	de,hl

	dec ixh
	jp	nz,1b

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	sprite multiplexing
;
	
_sat_update:
	ld	a,(reverse_sat)
	xor 1
	ld	(reverse_sat),a
	jp	nz,_reverse_sat

_directsat:
	ld	a,(visible_sprts)
	and 0xFC
	ret z
	ld	b,a
	ld	c,VDP
	ld	hl,ram_sat
	_setvdpwvram 0x1b00
1:	outi
	outi
	outi
	outi			; 16
	jp	nz,1b		; 10
	ld	a,0xD0
	out (VDP),a
	ret

_reverse_sat:
	ld	a,(visible_sprts)
	and 0xFC
	ret z
	ld	b,a
	ld	c,VDP
	ld	hl,ram_sat-4+8

	ld	e,b
	ld	d,0
	add hl,de
	ld	de,-8

	_setvdpwvram 0x1b00
1:	add hl,de
	outi
	outi
	outi
	outi
	jp	nz,1b
	ld	a,0xD0
	out (VDP),a
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; update main ship
;
	
_plot_spt:
		ld	hl,(aniframe)
		ld	a,l
		cp	h
		ret	z
		ld	(old_aniframe),a
		ld	hl,ms_ani
		ld	c,a
		ld	b,0
		add	hl,bc
		ld	l,(hl)
		ld	h,b
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		ld	e,l
		ld	d,h
		add	hl,hl
		add	hl,de
		ld	de,ms_spt
		add hl,de
		_setvdpwvram 0x3800
		ld	c,VDP
	.96	outi
		ret
	