
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	manage SAT entries of the main ship
;

put_ms_sprt:
	ld	a,(ms_state)
	cp	ms_explode
	jr	z,.expl
						; manage SAT entries of the main ship
	ld	hl,ram_sat
	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),0		; shape 0 hard wired
	inc hl
	ld	(hl),15
	inc hl

	ld	a,(yship)
	dec	a
	ld	c,a
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),4		; shape 4 hard wired
	inc hl
	ld	(hl),7
	inc hl

	ld 	a,(zship)
	add a,c				; a = yship-1+zship
	ld	(hl),a
	sub c				
	add a,xship_rel		; a = xship_rel + zship
	inc hl
	ld	(hl),a
	inc hl
	ld	(hl),8		; shape 8 hard wired
	inc hl
	ld	(hl),1
	ret
.expl:
						; manage SAT entries of the main ship
	ld	hl,ram_sat
	ld	a,(yship)
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),0		; shape 0 hard wired
	inc hl
	ld	(hl),10
	inc hl

	ld	a,(yship)
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),4		; shape 4 hard wired
	; ld	c,a
	inc hl
	ld	(hl),11
	inc hl

	ld	a,(yship)
	ld	(hl),a
	inc hl
	ld	(hl),xship_rel
	inc hl
	ld	(hl),8		; shape 8 hard wired
	inc hl
	ld	(hl),6
	ret
	
.landing:
	ld	hl,ram_sat+4*2
	ld 	a,(zship)
	ld  b,a

	ld	a,(reverse_sat)
	and a
	jr nz,.landing_rev
	
.landing_dir			; direct SAT
	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	d
	ld	(hl),a		; xship_rel
	inc hl
	ld	(hl),0		; shape 0 hard wired
	inc hl
	ld	(hl),15
	
	ld  de,-7
	add hl,de
	
	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	d
	ld	(hl),a		; xship_rel
	inc hl
	ld	(hl),4		; shape 4 hard wired
	ld	c,a
	inc hl
	ld	(hl),7

	ld  de,-7
	add hl,de
;shadow
	ld	a,(yship)
	add a,b 
	ld	(hl),a
	inc hl
	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	d
	add	a,b
	ld	(hl),a
	inc hl
	ld	(hl),8		; shape 8 hard wired
	inc hl
	ld	(hl),1
	ret
	
	
.landing_rev:	
;shadow
	ld	a,(yship)
	add a,b 
	ld	(hl),a
	inc hl

	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	d
	add	a,b
	ld	(hl),a
	inc hl
	ld	(hl),8		; shape 8 hard wired
	inc hl
	ld	(hl),1

	ld  de,-7
	add hl,de
	
;white layer
	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	d
	ld	(hl),a		; xship_rel
	inc hl
	ld	(hl),0		; shape 0 hard wired
	inc hl
	ld	(hl),15
	
	ld  de,-7
	add hl,de
;blue layer
	ld	a,(yship)
	dec	a
	ld	(hl),a
	inc hl
	ld	a,(xmap)
	ld  d,a
	ld	a,(xship)
	sub	d
	ld	(hl),a		; xship_rel
	inc hl
	ld	(hl),4		; shape 4 hard wired
	ld	c,a
	inc hl
	ld	(hl),7

	ld  de,-7
	add hl,de
	ret
