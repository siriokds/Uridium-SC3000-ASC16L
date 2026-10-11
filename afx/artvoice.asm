;*******************************************
; 60Hz voice player 
; ColecoVision version
;
; Each frame is 4 words
; The first 3 words are for channels 0,1,2
; Each word is a channel packed in this way 
; XXVV VVPP PPPP PPPP
;
; (However, it's little endian, so we actually see this:
; PPPP PPPP XXVV VVPP  (second byte PP is most significant) )
;
; XX = 00 always, 1X if the frame has ended
; VVVV = volume in the SN76489 format
; PPPPPPPPPP = period of the tone in 1-1023, 
; where 1 = 111860Hz to 1023 = 109Hz
;
; The last word is for the noise channel in periodic mode
; Again the format is
; XXVV VVPP PPPP PPPP
; XX, VVVV and PPPPPPPPPP are the same as above 
; but the  frequency is fixed at 3579545/512/15 = 466,08Hz
; only volume counts
; 
;
; Updated 8/13/2016 by artrag 
;
;*******************************************
;
; To use, simply load the address of your voice at "vocadr"
; and call "vocplay" 60 times per second (ie: during vblank)
; vocadr will be updated automatically, and will be zeroed
; when the voice is over. (Make sure it's zero before the
; first time you call vocplay if there's no sample ;) )
;




_SOUND	=	0x007F

; ---------------------------------
; Function mute - silence all three channels we use
; also zeros vocadr
; note: mutes the noise channel even though we don't use it
; ---------------------------------
_mute:
	ld	a,0x9F
	out	(_SOUND),a
	ld	a,0xBF
	out	(_SOUND),a
	ld	a,0xDF
	out	(_SOUND),a
	ld	a,0xFF
	out	(_SOUND),a
	ld  a,11100000B			; noise control
	out	(_SOUND),a			; periodic noise, frequency divided by 512 and 15
_mute2:
	ld	hl,0x0000
	ld	(_vocadr),hl
	ret
	
_vocset:
	ld	de,(_vocadr)
	ld	a,d
	or	e
	ret	nz
	ld (_vocadr),hl
	ret

; ---------------------------------
; Function vocplay - call every 1/60th second
;
; a - scratch
; hl - sample pointer
; d - voice command
; b - MSB of current word
; c - LSB of current word
; ---------------------------------
_vocplay:

	ld	a,(voice_off)
	and a
	jr nz,_mute2
; get sample pointer
	ld	hl,(_vocadr)
	ld	a,h
	or	l
	ret	z
; start processing loop for three voices
	;LD A,($FFF8+:_alarm)	; swap in page with audio data
	setpage2 $$_alarm

	ld	d,0x80
_00106:

; read two bytes (little endian format)
; final word ends up being he, but what the hell ;)

	ld	c,(hl)				; PPPP PPPP
	inc	hl
	ld	b,(hl)				; XXVV VVPP

	bit	7,b					; check for terminate flag
	jp	nz,_mute			; silences speakers and zeros pointer
	
	inc	hl

	ld	a, c				; first byte out - tone command (c & 0x0f)|d
	and	0x0F
	or	d
	out	(_SOUND),a			; Channel period low nibble

	rr	b					; c >>= 4 - second byte is 4 bits from LSB and 2 from MSB
	rr  c
	rr	b
	rr  c

	rr  c
	rr  c

	ld	a,c
	and	0x3F
	out	(_SOUND),a
	
	ld	a,b
	and	0x0F				; (b>>2)&0x0f - volume

	or d
	or 0x10
	out	(_SOUND),a
	
; next iteration of loop
	ld	a,d
	add	a,0x20
	ld	d,a
	cp 0xe0
	jr	nz,_00106			; loop on 3 channels 
	
	inc	hl					; drop one byte
	ld  a,(hl)
	rra
	rra
	and	0x0F				; volume				
	or  0xF0
	out	(_SOUND),a			; periodic noise, frequency divided by 15
	inc	hl
	
; update the pointer and return
	ld	(_vocadr),hl
	ret
