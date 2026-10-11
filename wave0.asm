	call	front_alarm
	
	call	rand8
	and	7
	ld	l,a
	ld	h, high spritecolors
	ld	a,(hl)	
	ld	iyl,a		; color
	ld	a,l
	.4	add	a,a

	add	a,64
	ld	b,a			; frame
	
	ld	a,(dxmap)
	and	0x80
	jr	z,.pos
.neg
	ld	de,-16		; initial X 
	ld	c,+1		; enemies going right
	exx	
	ld 	de,1		; enemy speed = 1
	exx
	jr	1f
.pos
	ld	de,256		; initial X 
	ld	c,1+64		; enemies going left
	ld	a,4
	add	a,b
	ld	b,a			; opposite frame
	exx	
	ld 	de,-1		; enemy speed = -1
	exx
1:
	exx	
	ld 	a,(yship)
	add a,-36
	ld	(goal_supp),a	; Y goal in memory
	exx		
	
	ld	hl,(xmap)
	add	hl,de

	ld  ix,enemies
	ld	iyh,max_enem
	ld  de,enemy_data
	ld	a,64+8			; a = current Y 
	
1:
	bit	0,(ix+enemy_data.status)
	jr  nz,.next				; this is already active, try the next

	ld  (ix+enemy_data.status),c
	ld	(ix+enemy_data.frame),b

	ld  (ix+enemy_data.kind),0
	exx
	ld	b,iyl
	ld	(ix+enemy_data.color),b
	ld	(ix+enemy_data.speed),e
	ld	(ix+enemy_data.speed+1),d
	ld  hl,(goal_supp)
	ld	(ix+enemy_data.goaly),l		; goal Y
	ld	bc,20
	add hl,bc
	ld  (goal_supp),hl
	ld  (ix+enemy_data.fy),0
	ld  (ix+enemy_data.dyy),127
	ld  (ix+enemy_data.dyy+1),0
	exx

	; push	bc
	; ld bc,16
	; add hl,bc 
	ld  (ix+enemy_data.x),l
	ld  (ix+enemy_data.x+1),h
	; pop	bc
	
	ld  (ix+enemy_data.y),a
	add	a,32
	
	call	set_size

	add ix,de
	dec	iyh			
	ret	z
	cp	191-16
	jr	c,1b
	ret

.next
	add ix,de
	dec	iyh
	ret	z
	jr	1b