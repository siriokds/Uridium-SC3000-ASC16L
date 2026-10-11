

before_atan_tab:
        ; align to byte        
        ; align #100
        ds ((($-1)/#100)+1)*#100-$
        
        ;;;;;;;; atan(2^(x/32))*128/pi ;;;;;;;;
atan_tab:   
        db #20,#20,#20,#21,#21,#22,#22,#23,#23,#23,#24,#24,#25,#25,#26,#26
        db #26,#27,#27,#28,#28,#28,#29,#29,#2A,#2A,#2A,#2B,#2B,#2C,#2C,#2C
        db #2D,#2D,#2D,#2E,#2E,#2E,#2F,#2F,#2F,#30,#30,#30,#31,#31,#31,#31
        db #32,#32,#32,#32,#33,#33,#33,#33,#34,#34,#34,#34,#35,#35,#35,#35
        db #36,#36,#36,#36,#36,#37,#37,#37,#37,#37,#37,#38,#38,#38,#38,#38
        db #38,#39,#39,#39,#39,#39,#39,#39,#39,#3A,#3A,#3A,#3A,#3A,#3A,#3A
        db #3A,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3B,#3C,#3C,#3C,#3C
        db #3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3C,#3D,#3D,#3D,#3D,#3D,#3D,#3D
        db #3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3D,#3E,#3E,#3E,#3E
        db #3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E
        db #3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3E,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
        db #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
 
        ;;;;;;;; log2(x)*32 ;;;;;;;; 
log2_tab:  
        db #00,#00,#20,#32,#40,#4A,#52,#59,#60,#65,#6A,#6E,#72,#76,#79,#7D
        db #80,#82,#85,#87,#8A,#8C,#8E,#90,#92,#94,#96,#98,#99,#9B,#9D,#9E
        db #A0,#A1,#A2,#A4,#A5,#A6,#A7,#A9,#AA,#AB,#AC,#AD,#AE,#AF,#B0,#B1
        db #B2,#B3,#B4,#B5,#B6,#B7,#B8,#B9,#B9,#BA,#BB,#BC,#BD,#BD,#BE,#BF
        db #C0,#C0,#C1,#C2,#C2,#C3,#C4,#C4,#C5,#C6,#C6,#C7,#C7,#C8,#C9,#C9
        db #CA,#CA,#CB,#CC,#CC,#CD,#CD,#CE,#CE,#CF,#CF,#D0,#D0,#D1,#D1,#D2
        db #D2,#D3,#D3,#D4,#D4,#D5,#D5,#D5,#D6,#D6,#D7,#D7,#D8,#D8,#D9,#D9
        db #D9,#DA,#DA,#DB,#DB,#DB,#DC,#DC,#DD,#DD,#DD,#DE,#DE,#DE,#DF,#DF
        db #DF,#E0,#E0,#E1,#E1,#E1,#E2,#E2,#E2,#E3,#E3,#E3,#E4,#E4,#E4,#E5
        db #E5,#E5,#E6,#E6,#E6,#E7,#E7,#E7,#E7,#E8,#E8,#E8,#E9,#E9,#E9,#EA
        db #EA,#EA,#EA,#EB,#EB,#EB,#EC,#EC,#EC,#EC,#ED,#ED,#ED,#ED,#EE,#EE
        db #EE,#EE,#EF,#EF,#EF,#EF,#F0,#F0,#F0,#F1,#F1,#F1,#F1,#F1,#F2,#F2
        db #F2,#F2,#F3,#F3,#F3,#F3,#F4,#F4,#F4,#F4,#F5,#F5,#F5,#F5,#F5,#F6
        db #F6,#F6,#F6,#F7,#F7,#F7,#F7,#F7,#F8,#F8,#F8,#F8,#F9,#F9,#F9,#F9
        db #F9,#FA,#FA,#FA,#FA,#FA,#FB,#FB,#FB,#FB,#FB,#FC,#FC,#FC,#FC,#FC
        db #FD,#FD,#FD,#FD,#FD,#FD,#FE,#FE,#FE,#FE,#FE,#FF,#FF,#FF,#FF,#FF
		
sin_table:
    dw    0,    6,   12,   18,   25,   31,   37,   43,   49,   56,   62,   68,   74,   80,   86,   92
    dw   97,  103,  109,  115,  120,  126,  131,  136,  142,  147,  152,  157,  162,  167,  171,  176
    dw  181,  185,  189,  193,  197,  201,  205,  209,  212,  216,  219,  222,  225,  228,  231,  234
    dw  236,  238,  241,  243,  244,  246,  248,  249,  251,  252,  253,  254,  254,  255,  255,  255
cos_table:
    dw  256,  255,  255,  255,  254,  254,  253,  252,  251,  249,  248,  246,  244,  243,  241,  238
    dw  236,  234,  231,  228,  225,  222,  219,  216,  212,  209,  205,  201,  197,  193,  189,  185
    dw  181,  176,  171,  167,  162,  157,  152,  147,  142,  136,  131,  126,  120,  115,  109,  103
    dw   97,   92,   86,   80,   74,   68,   62,  56,    49,   43,   37,   31,   25,   18,   12,    6
    dw    0,   -6,  -12,  -18,  -25,  -31,  -37,  -43,  -49,  -56,  -62,  -68,  -74,  -80,  -86,  -92
    dw  -97, -103, -109, -115, -120, -126, -131, -136, -142, -147, -152, -157, -162, -167, -171, -176
    dw -181, -185, -189, -193, -197, -201, -205, -209, -212, -216, -219, -222, -225, -228, -231, -234
    dw -236, -238, -241, -243, -244, -246, -248, -249, -251, -252, -253, -254, -254, -255, -255, -255
    dw -256, -255, -255, -255, -254, -254, -253, -252, -251, -249, -248, -246, -244, -243, -241, -238
    dw -236, -234, -231, -228, -225, -222, -219, -216, -212, -209, -205, -201, -197, -193, -189, -185
    dw -181, -176, -171, -167, -162, -157, -152, -147, -142, -136, -131, -126, -120, -115, -109, -103
    dw  -97,  -92,  -86,  -80,  -74,  -68,  -62,  -56,  -49,  -43,  -37,  -31,  -25,  -18,  -12,   -6
    dw    0,    6,   12,   18,   25,   31,   37,   43,   49,   56,   62,   68,   74,   80,   86,   92
    dw   97,  103,  109,  115,  120,  126,  131,  136,  142,  147,  152,  157,  162,  167,  171,  176
    dw  181,  185,  189,  193,  197,  201,  205,  209,  212,  216,  219,  222,  225,  228,  231,  234
    dw  236,  238,  241,  243,  244,  246,  248,  249,  251,  252,  253,  254,  254,  255,  255,  255
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-----------------------------------------------
; Source: https://www.msx.org/forum/msx-talk/development/8-bit-atan2?page=0
; 8-bit atan2
; Calculate the angle, in a 256-degree circle.
; The trick is to use logarithmic division to get the y/x ratio and
; integrate the power function into the atan table. 
;   input
;   B = x, C = y    in -128,127
;
;   output
;   A = angle       in 0-255
;      |
;  q1  |  q0
;------+-------
;  q3  |  q2
;      |
atan2:  
        ld  de,#8000           
        
        ld  a,c
        add a,d
        rl  e               ; y-                    
        
        ld  a,b
        add a,d
        rl  e               ; x-                    
        
        dec e
        jp  z,atan2_q1
        dec e
        jp  z,atan2_q2
        dec e
        jp  z,atan2_q3
        
atan2_q0:         
        ld  h,log2_tab / 256
        ld  l,b
        
        ld  a,(hl)          ; 32*log2(x)
        ld  l,c
        
        sub (hl)          ; 32*log2(x/y)
        
        jr  nc,atan2_1f           ; |x|>|y|
        neg             ; |x|<|y|   A = 32*log2(y/x)
atan2_1f:      
        ld  l,a

        ld  h,atan_tab / 256
        ld  a,(hl)
        ret c           ; |x|<|y|
        
        neg
        and #3F            ; |x|>|y|
        ret
                
atan2_q1:     
        ld  a,b
        neg
        ld  b,a
        call    atan2_q0
        neg
        and #7F
        ret
        
atan2_q2:     
        ld  a,c
        neg
        ld  c,a
        call    atan2_q0
        neg
        ret     
        
atan2_q3:     
        ld  a,b
        neg
        ld  b,a
        ld  a,c
        neg
        ld  c,a
        call    atan2_q0
        add a,128
        ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   input
;   A = angle       in 0-255
;
;   output
;   BC = sin(A)		in -256,256
;	DE = cos(A)    	in -256,256
		
getsincos:
	ld	l,a
	ld	h,0
	add	hl,hl
	ld de,sin_table
	add hl,de
	ld	c,(hl)
	inc hl
	ld  b,(hl)
	ld  de,cos_table-sin_table-1
	add hl,de
	ld	e,(hl)
	inc hl
	ld  d,(hl)
	ret

	

; in
;	IX -> enemy ship
; out
;	active bullet in list enem_bullets

book_directional_shoot:
	
	ld  iy,enem_bullets
	ld  de,enemy_data
	
	DUP	max_enem_bullets

	bit	0,(iy+enemy_data.status)
	jr  z,.activate_this
	add iy,de

	EDUP
	ret

.activate_this:
	ld  (iy+enemy_data.status),1		; active

	ld	l,(ix+enemy_data.speed)
	ld	h,(ix+enemy_data.speed+1)
	ld  (iy+enemy_data.speed),l
	ld  (iy+enemy_data.speed+1),h
	
	ld	hl,(xship)
	ld	e,(ix+enemy_data.x)
	ld	d,(ix+enemy_data.x+1)
	and	a
	sbc	hl,de
	ld b,l

	ld a,(yship)
	sub (ix+enemy_data.y)
	ld  c,a
	
	call	atan2						; a = angle in 0-255
	call	getsincos
	
	ld	hl,0
	.(enemy_bullet_speed)	add	hl,de	
	ld	(iy+enemy_data.dxx),l
	ld	(iy+enemy_data.dxx+1),h
	
	ld	hl,0
	.(enemy_bullet_speed)	add	hl,bc
	ld	(iy+enemy_data.dyy),l
	ld	(iy+enemy_data.dyy+1),h
	
	ld  (iy+enemy_data.frame),14*4		; round bullet

	call	set_size2	; set  xoff,yoff,xsize,ysize for sprite collision

	ld	l,(ix+enemy_data.x)
	ld	h,(ix+enemy_data.x+1)
	ld  (iy+enemy_data.x),l
	ld  (iy+enemy_data.x+1),h

	ld  a,(ix+enemy_data.y)
	ld  (iy+enemy_data.y),a
	ld  (iy+enemy_data.cntr),(256+32+24)/enemy_bullet_speed

	; ld  (iy+enemy_data.color),11
	
	ld a,1			; enemy turret shoot
	call AFXPLAY
	ret

	