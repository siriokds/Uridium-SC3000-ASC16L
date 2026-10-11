
attract_mode:
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
	ld	(already_dead),a	; reset at level start, set after you die
	inc	a
	ld	(next_level),a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.restart:
	ld	hl,0
	ld	(xmap),hl
	call 	ayFX_END
	call	PT3_MUTE
	call	intro_anim

	ld	a,1
	ld	(god_mode),a

	call 	set_level_name
	
	xor a
	ld	(aniframe),a
	ld	(anispeed),a
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

	call	ayFX_SETUP	
	xor	a
	ld	(halt_game),a
	ld	(halt_gamef1),a
	ld	(JIFFY),a
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	init ground enemies
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	call	turret_init
	ld 	a,16
	ld 	(zship),a
	
.main_loop:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; place MS in the SAT and test for collision
	call	put_ms_sprt
	call	dummy_control

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run NCPS FSM
	call	npc_loop			; manage active enemies
	call	wave_timer			; activate new enemies

	call	enemy_bullet_loop	; manage enemy bullets
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run MS bullets FSM
	call	ms_bullet_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; place NPCS sprites in the SAT in RAM
	call	plot_enemy

; wait refresh and update map position
	ld hl,JIFFY
	xor a
1:	cp (hl)
	jr nc,1b
	xor	a
	ld	(hl),a

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
	
	jr	nc,.end_attractmode
	call	_joy_read
	and	0x1F
	jr	nz,.end_attractmode
	
	jp	.main_loop
	
.end_attractmode
	xor	a
	ld	(god_mode),a
	
	pop	af
	pop	af
	jp title_screen
	; ret
	
	
dummy_control:
	
	ld 	ix,chkpoint
loopchkpnt	
	ld	hl,(xship)
	ld  e,(ix+0)
	ld  d,(ix+1)
	and a
	sbc hl,de
	jr	c,nextchkpnt
	add hl,de
	ld  e,(ix+4)
	ld  d,(ix+5)
	and a
	sbc hl,de
	jr	c,doaction
	
nextchkpnt
	ld bc,4
	add ix,bc
	jp 	loopchkpnt
	
doaction:	
	ld	a,(yship)
	add a,(ix+2)
	ld	(yship),a
	ret

chkpoint:
	dw	0		,0
	dw	568		,+1
	dw	568+48	,0
	dw  1510	,-1
	dw  1510+78	,0
	dw  2528	,1
	dw  2528+64 ,0
	dw  5000