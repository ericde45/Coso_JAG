

coso_OLD			equ				0			;0=ANCIENNE VERSION,1=NOUVELLE			

off22	equ		0					; rs.l	1	;ptr courant dans pattern								4
off0	equ		4					; rs.l	1	;ptr base patterns										4
off34	equ		8					; rs.w	1	;ptr fin musique										2

off4	equ		10					; rs.w	1	;ptr patterns (.W au lieu de .L)						2
offa	equ		12					; rs.l	1	;ptr base modulation volume								4
offe	equ		16					; rs.w	1	;ptr modulation volume (.W au lieu de .L)				2
off12	equ		18					; rs.l	1	;ptr base modulation fr‚quence							4
off30	equ		22					; rs.w	1	;ptr modulation fr‚quence (.W au lieu de .L)			2

off38	equ		24					; rs.l	1	;incr‚ment pour crescendo					4

off8	equ		28					; rs.b	1	;											1
off9	equ		29					; rs.b	1	;											1

off16	equ		30					; rs.b	1	;											1
off17	equ		31					; rs.b	1	;											1
off18	equ		32					; rs.b	1	;											1
off19	equ		33					; rs.b	1	;											1
off1a	equ		34					; rs.b	1	;											1
off1b	equ		35					; rs.b	1	;											1
off1c	equ		36					; rs.b	1	;											1
off1d	equ		37					; rs.b	1	;											1
off1e	equ		38					; rs.b	1	;											1
off1f	equ		39					; rs.b	1	;											1
off21	equ		40					; rs.b	1	;											1

off26	equ		41					; rs.b	1	;											1
off27	equ		42					; rs.b	1	;											1
off28	equ		43					; rs.b	1	;15-volume sonore de la voix				1
off2a	equ		44					; rs.b	1	;0,1 ou 2=type de son						1
off2b	equ		45					; rs.b	1	;											1
off2c	equ		46					; rs.b	1	;											1
off2d	equ		47					; rs.b	1	;volume sonore calculé						1
off2e	equ		48					; rs.b	1	;											1
;off3c	equ		47
off3c	equ		49

.opt "~Oall"

.text

			.68000

; init
	MOVEQ	#1,D0
	lea		MUSIC,a0
	bsr		INITMUSIC

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6


	bsr		PLAYMUSIC
	lea		PSGREG,A0		

	bsr		PLAYMUSIC
	lea		PSGREG,A0		

	bsr		PLAYMUSIC
	lea		PSGREG,A0		


coso_envoi_registres:
	MOVEM.L			A0-A1,-(A7)
	LEA.L			PSGREG+2,A0											; = c177be
	lea		 		registres_virtuels_YM_c04f4c(PC),A1
	MOVE.B			(A0),(A1)+
	MOVE.B			4(A0),(A1)+
	MOVE.B			8(A0),(A1)+
	MOVE.B			12(A0),(A1)+
	MOVE.B			16(A0),(A1)+
	MOVE.B			20(A0),(A1)+
	MOVE.B			24(A0),(A1)+
	MOVE.B			28(A0),(A1)+
	MOVE.B			32(A0),(A1)+
	MOVE.B			36(A0),(A1)+

	TST.B 			flagdigit
	BEQ.B 			coso_envoi_registres_ret2
; pas de gestion des digits
	;MOVE.B 			#$0f,(A6,$002a) == $00c177e6 [00]
	;BT .B			coso_envoi_registres_ret1
coso_envoi_registres_ret2:
	MOVE.B 			40(A0),(A1)+
coso_envoi_registres_ret1:
	MOVEM.L 		(A7)+,A0-A1
	RTS

; replay
PLAYMUSIC:
	LEA	PSGREG(PC),A6

;	IFEQ	CUTMUS
;	TST.B	BLOQUEMUS-PSGREG(A6)
;	BNE.S	L25A
;	BNE	ZEROSND
;	BEQ.S	L160
;	TAS	L813-PSGREG(A6)
;	BEQ	ZEROSND
;	BNE.S	L15E
;	clr.B	$22(A6)
;	clr.B	$26(A6)
;	clr.B	$2A(A6)
;	MOVEM.L	$1C(A6),D0-D3
;	MOVEM.L	D0-D3,$FFFF8800.W
;L15E:
;	RTS
;L160:
;	ENDC


	move.b	#$C0,$1E(A6)		;pour que ‡a tienne...

	SUBQ.B	#1,L80E-PSGREG(A6)
	BNE.S	L180
	MOVE.B	L810-PSGREG(A6),L80E-PSGREG(A6)
	MOVEQ	#0,D5
	LEA	voice0(PC),A0
	BSR		L25C
	LEA	voice1(PC),A0
	BSR.s	L25C
	LEA	voice2(PC),A0
	BSR.s	L25C
L180:
	LEA		voice0(PC),A0
	BSR		L39A
	move	d0,6(A6)
	MOVE.B	D0,2(A6)
	MOVE.B	D1,$22(A6)

	LEA	voice1(PC),A0
	BSR		L39A
	move	d0,$E(A6)
	MOVE.B	D0,$A(A6)
	MOVE.B	D1,$26(A6)

	LEA	voice2(PC),A0
	BSR		L39A
	move	D0,$16(A6)
	MOVE.B	D0,$12(A6)
	MOVE.B	D1,$2A(A6)

	TST.B	flagdigit-PSGREG(a6)
	bne.s	TRK
	jmp		coso_envoi_registres
	;MOVEM.L	(A6),D0-D7/A0-A2
	;MOVEM.L	D0-D7/A0-A2,$FFFF8800.W
L25A:	RTS

TRK:
	or.b	#$24,$1e(a6)		;reg 7
	jmp		coso_envoi_registres
	
	;MOVEM.L	(A6),D1-D7/A0-A2
	;IFNE	SYSTEM
	;MOVE	SR,D0
	;MOVE	#$2700,SR
	;ENDC
	;MOVEM.L	D1-D7/A0-A2,$FFFF8800.W
	;IFNE	SYSTEM
	;MOVE.B	#$A,$FFFF8800.W
	;MOVE	D0,SR
	;ENDC
	;IFEQ	EQUALISEUR
	MOVE.B	#$F,$2A(A6)
	;ENDC
	RTS
	
	
; calcule nouvelle note
;
L25C:
	SUBQ.B	#1,off26(A0)
	BPL.S	L25A
	MOVE.B	off27(A0),off26(A0)
	MOVE.L	off22(A0),A1
L26C:
	MOVE.B	(A1)+,D0
	CMP.B	#$FD,D0
	BLO		L308
	EXT	D0
	ADD	D0,D0
	JMP		coso_CODEFD+(3*2)(PC,D0.w)

coso_CODEFD:
	BRA.S	L2F4		;$FD
	BRA.S	L2E2		;$FE
				;$FF

	.if		coso_OLD=1
; ANCIENNE VERSION
	moveq	#$c,d1
	add	off4(a0),d1
	cmp	off34(a0),d1
	blS.S	L288
	clr	d1
	ST	BOUCLE-PSGREG(A6)
L288:
	MOVE.L	off0(a0),a1
	add		d1,a1
	.endif
	.if 	coso_OLD=0
; NOUVELLE VERSION
	move	off4(a0),d1
	cmp	off34(a0),d1
	blS.S	L288
	tst.b	off21(a0)		;nouveau replay !!!!
	bne.s	L288			;pour bien boucler !!!!
	clr	d1
	move	d5,off4+off3c(a0)
	move	d5,off4+off3c*2(a0)
	ST		BOUCLE-PSGREG(A6)
L288:
	MOVE.L	off0(a0),a1
	add	d1,a1
	add	#$C,d1
	endif

	move	d1,off4(a0)

	MOVEQ	#0,D1
	move.b	(a1)+,D1
	move.b	(a1)+,off2c(A0)
	move.b	(a1)+,off16(A0)
	moveq	#$10,d0
	add.b	(a1)+,D0
	bcc.s	L2B4
	move.b	d0,off28(A0)		;F0-FF=volume … soustraire
	BRA.S	L2C4
L2B4:	add.b	#$10,d0
	bcc.S	L2C4
	move.B	d0,L810-PSGREG(A6)	;E0-EF=vitesse
L2C4:	ADD	D1,D1
	MOVE.L	L934(PC),A1
	ADD	$C+2(A1),D1
	ADD	(A1,D1.W),A1

	MOVE.L	A1,off22(A0)
	BRA.s	L26C

L2E2:
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	BRA		L26C
L2F4:
	MOVE.B	(A1)+,d0
	move.b	d0,off27(A0)
	MOVE.B	d0,off26(A0)
	MOVE.L	A1,off22(A0)
	RTS

L308:
	MOVE.B	D0,off8(a0)
	MOVE.B	(A1)+,D1
	MOVE.B	D1,off9(a0)
	AND	#$E0,D1			;d1=off9&$E0
	BEQ.S	.L31C
	MOVE.B	(A1)+,off1f(A0)
.L31C:	MOVE.L	A1,off22(A0)
	MOVE.L	D5,off38(A0)
	TST.B	D0
	BMI.S	L398
	MOVE.B	off9(a0),D0
	eor.b	d0,d1			;d1=off9&$1F
	ADD.B	off16(A0),D1

	MOVE.L	L934(PC),A1

	CMP	$26(A1),D1
	BLS.S	coso_NOBUG2
	CLR	D1
coso_NOBUG2:
	ADD	D1,D1
	ADD	8+2(A1),D1
	ADD	(A1,D1.W),A1

	move	d5,offe(A0)
	MOVE.B	(a1)+,d1
	move.b	d1,off17(A0)
	MOVE.B	d1,off18(A0)
	MOVEQ	#0,D1
	MOVE.B	(a1)+,D1
	MOVE.B	(a1)+,off1b(A0)
;	MOVE.B	#$40,off2e(A0)
	clr.b	off2e(a0)
	MOVE.B	(a1)+,D2
	MOVE.B	D2,off1c(A0)
	MOVE.B	D2,off1d(A0)
	MOVE.B	(a1)+,off1e(A0)
	MOVE.L	a1,offa(A0)
	add.b	d0,d0			;test bit 6
	bpl.s	L37A
	MOVE.B	off1f(A0),D1
L37A:
	MOVE.L	L934(PC),A1
	CMP	$24(A1),D1
	BLS.S	coso_NOBUG3
	CLR	D1
coso_NOBUG3:
	ADD	D1,D1

	ADD	4+2(A1),D1
	ADD	(A1,D1.W),A1

	MOVE.L	a1,off12(A0)
	move	d5,off30(A0)
	MOVE.B	D5,off1a(A0)
	MOVE.B	D5,off19(A0)
L398:	
	RTS

;
; calcul de la note a jouer
;
L39A:	
	MOVEQ	#0,D7
	MOVE	off30(a0),d6
L3A0:	
	TST.B	off1a(A0)
	BEQ.S	L3AE
	SUBQ.B	#1,off1a(A0)
	BRA	L4C01
L3AE:	
	MOVE.L	off12(A0),A1
	add	d6,a1
L3B6:	
	move.b	(a1)+,d0
	CMP.B	#$E0,D0
	BLO	L4B0
;	CMP.B	#$EA,D0		;inutile ???
;	BHS	L4B0

	EXT	D0
	ADD	#32,D0
	MOVE.B	coso_CODES(PC,D0.W),D0
	JMP	coso_BRANCH(PC,D0.W)

coso_CODES:
	DC.B	E0-coso_BRANCH
	DC.B	E1-coso_BRANCH
	DC.B	E2-coso_BRANCH
	DC.B	E3-coso_BRANCH
	DC.B	E4-coso_BRANCH
	DC.B	E5-coso_BRANCH
	DC.B	E6-coso_BRANCH
	DC.B	E7-coso_BRANCH
	DC.B	E8-coso_BRANCH
	DC.B	E9-coso_BRANCH
	DC.B	EA-coso_BRANCH
	;IFEQ	DIGIT
	DC.B	EB-coso_BRANCH
	DC.B	EC-coso_BRANCH
	;ENDC
	EVEN
coso_BRANCH:

;	IFEQ	PRG
;BUG:	DCB.L	2,$4A780001
;	DCB.L	$100-$EA,$4A780001
;	ENDC

E1:	BRA	L4C01
E0:
	moveq	#$3f,d6		;$E0
;clr d6 … pr‚sent !!!!
	and.B	(A1),D6
	BRA.S	L3AE
E2:
	clr	offe(a0)
	MOVE.B	#1,off17(A0)
	addq	#1,d6
	bra.s	L3B6

E9:
	jmp		coso_escape_ENV1								; =C0364E


	;IFEQ	DIGIT
	;move	sr,D0
	;move	#$2700,sr
	;ENDC
	;MOVE.B	#$B,$FFFF8800.W
	;move.b	(A1)+,$FFFF8802.W
	;move.l	#$0C0C0000,$FFFF8800.W
	;move.l	#$0D0D0A0A,$FFFF8800.W
	;IFEQ	DIGIT
	;IFNE	SYSTEM
	;MOVE.B	#$A,$FFFF8800.W
	;ENDC
	;move	D0,sr
	;ENDC


coso_back_from_coso_escape_ENV1:
	addq	#2,d6
	bra.S	L3B6
E7:
	moveq	#0,d0
	move.b	(A1),D0
	ADD	D0,D0

	MOVE.L	L934(PC),A1
	ADD	4+2(A1),D0
	ADD	(A1,D0.W),A1

	MOVE.L	A1,off12(A0)
	clr	d6
	BRA	L3B6
EA:	move.b	#$20,off9(a0)
	move.b	(a1)+,off1f(a0)
	addq	#2,d6
	bra	L3B6
E8:	move.b	(A1)+,off1a(A0)
	addq	#2,d6
	BRA	L3A0

E4:	clr.b	off2a(A0)
	MOVE.B	(A1)+,d7
	addq	#2,d6
	BRA	L3B6		;4AE
E5:	MOVE.B	#1,off2a(A0)
	addq	#1,d6
	BRA	L3B6
E6:	MOVE.B	#2,off2a(A0)
	addq	#1,d6
	BRA	L3B6		;4AE

E3:	addq	#3,d6
	move.b	(A1)+,off1b(A0)
	move.b	(A1)+,off1c(A0)
	bra	L3B6		;nouveau
	;IFEQ	DIGIT
EB:
	CLR.B	flagdigit-PSGREG(a6)
	;clr.b	$fffffa19.w
	ADDQ	#1,D6
	BRA	L3B6
EC:
	ST	flagdigit-PSGREG(a6)
	moveq	#0,d0
	move.b	(a1)+,d0
;
	;jmp		coso_escape_DIGIT2
	
	add	d0,d0
	MOVE.L	L934(PC),A2


	ADD	28+2(A2),D0
	ADD	(A2,D0.W),A2

	;IFEQ	PCRELATIF
	;LEA	L51(PC),A3
	;SUB.L	A3,A2
	;MOVE	A2,(A3)
	;ELSEIF
	MOVE.L	A2,L51-PSGREG(A6)
	;ENDC

	;clr.b	$fffffa19.w
	;MOVE.B	(A1)+,$fffffa1f.w				; 
	addq.l	#1,A1
	;move.b	#1,$fffffa19.w

	addq	#3,d6

	move	d6,off30(a0)
;MC	moveq	#0,d1
;MC	MOVEQ	#0,D0
	rts
	;ENDC

;L4AE:	move.b	(a1)+,d0
L4B0:
	MOVE.B	d0,off2b(A0)
	addq	#1,d6
L4C01:	move	d6,off30(a0)
;
; modulation volume
;
	move	offe(a0),d6
L4C0:	TST.B	off19(A0)
	BEQ.S	L4CC
	SUBQ.B	#1,off19(A0)
	BRA.S	L51A
L4CC:	SUBQ.B	#1,off17(A0)
	BNE.S	L51A
	MOVE.B	off18(A0),off17(A0)

	MOVE.L	offa(A0),A1
	add	d6,a1
	move.b	(A1)+,D0
	CMP.B	#$E0,D0
	BNE.S	L512
	moveq	#$3f,d6
; clr d6 a present
	and.b	(A1),D6
	subq	#5,D6
	move.l	offa(a0),a1
	add	d6,a1
	move.b	(a1)+,d0
L512:
	CMP.B	#$E8,D0
	BNE.S	L4F4
	addq	#2,d6
	move.b	(A1)+,off19(A0)
	BRA.S	L4C0
L4F4:	CMP.B	#$E1,D0
	BEQ.S	L51A
	MOVE.B	d0,off2d(A0)
	addq	#1,d6
L51A:	move	d6,offe(a0)

	clr	d5
	MOVE.B	off2b(A0),D5
	BMI.S	L528
	ADD.B	off8(a0),D5
	ADD.B	off2c(A0),D5
L528:
	add.b	D5,D5
;	LEA	L94E(PC),A1
;	MOVE	(A1,d5.w),D0
	MOVE	L94E-PSGREG(A6,D5.W),D0

	move.b	off2a(A0),D1	;0,1 ou 2
	beq.S	L57E

	MOVE.B	off21(A0),D2
	ADDQ	#3,D2

	subq.b	#1,D1
	BNE.S	L578
	subq	#3,d2
	MOVE.B	off2b(A0),D7
	bclr	#7,d7
	bne.s	L578		;BMI impossible !!!
	add.b	off8(a0),d7
L578:

	BSET	D2,$1E(A6)
L57E:
	tst.b	d7
	BEQ.S	L594
	not.b	d7
	and.b	#$1F,D7
	MOVE.B	D7,$1A(A6)
L594:
	;IFEQ	MMME
	tst.b	mmme-PSGREG(a6)
	bne		newrep
	;ENDC

	TST.B	off1e(A0)
	BEQ.S	L5A4
	SUBQ.B	#1,off1e(A0)
	BRA.S	L5FA
L5A4:
	clr	d2
	MOVE.B	off1c(A0),D2

;	bclr	#7,d2		;nouveau replay
;	beq.s	.ok		;BUG ????
;	add.b	d2,d2
;.ok

	clr	d1
	MOVE.B	off1d(A0),D1
	tst.b	off2e(a0)
	bmi.S	L5CE
	SUB.B	off1b(A0),D1
	BCC.S	L5DC
	tas	off2e(a0)	;ou bchg
	MOVEQ	#0,D1
	BRA.S	L5DC
L5CE:	ADD.B	off1b(A0),D1
	ADD.B	d2,d2
	CMP.B	d2,D1
	BCS.S	L5DA
	and.b	#$7f,off2e(a0)	;ou bchg
	MOVE.B	d2,D1
L5DA:	lsr.b	#1,d2
L5DC:	MOVE.B	D1,off1d(A0)
L5E0:
	sub	d2,D1

	ADD.B	#$A0,D5
	BCS.S	L5F8
	moveq	#$18,d2

	add	d1,d1
	add.b	d2,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d2,d5
	bcs.s	L5F8
	add	d1,d1
	add.b	d2,d5
	bcs.s	L5F8
	add	d1,d1
L5F8:	ADD	D1,D0
;;	EOR.B	#1,d6		;inutilis‚ !!!
;	MOVE.B	d6,off2e(A0)
L5FA:
	BTST	#5,off9(a0)
	BEQ.s	L628
	moveq	#0,D1
	MOVE.B	off1f(A0),D1
	EXT	D1
	swap	d1
	asr.l	#4,d1		;lsr.l #4,d1 corrige bug ???
	add.l	d1,off38(a0)
	SUB	off38(a0),D0
L628:
	MOVE.B	off2d(A0),D1

	;IFEQ	TURRICAN
	SUB.B	off28(A0),D1
	BPL.S	coso_NOVOL
	CLR	D1
coso_NOVOL:
	RTS
	;ELSEIF
	;MOVEQ	#-16,D2		;DEBUGGAGE VOLUME
	;AND.B	D1,D2
	;SUB.B	D2,D1
	;SUB.B	off28(A0),D1
	;BMI.S	.NOVOL
	;OR.B	D2,D1
	;RTS
;.NOVOL:
	;MOVE	D2,D1
	;RTS
	;ENDC

	;IFEQ	MMME
newrep:
	tst.b	off1e(a0)
	beq.s	coso_1dollar
	subq.b	#1,off1e(a0)
	bra.s	coso_quit

coso_1dollar:
	clr	d1
	clr	d2
	clr	d3
	move.b	off1d(a0),d1
	move.b	off1c(a0),d2
	move.b	off1b(a0),d3
;
; d3 peut-il etre lib‚r‚ comme au-dessus avec une gestion en bytes ???
;
	tst.b	off2e(a0)
	bpl.s	coso_monte		;OU BMI ???
	sub	d3,d1
	bpl.s	coso_nextedz1
	clr	d1
	bchg	#7,off2e(a0)
	bra.s	coso_nextedz1
coso_monte:
	add	d2,d2
	add	d3,d1
	cmp	d2,d1
	blo.s	coso_nextedz11
	move	d2,d1
	bchg	#7,off2e(a0)
coso_nextedz11:
	lsr	#1,d2
coso_nextedz1:
	move.b	d1,off1d(a0)
	sub	d2,d1
	muls	d0,d1
	asl.l	#6,d1
	swap	d1
	add	d1,d0
coso_quit:
	btst	#5,off9(a0)
	beq.s	coso_novol
	clr	d1
	move.b	off1f(a0),d1
	ext	d1
	ext.l	d1
	add.l	off38(a0),d1
	move.l	d1,off38(a0)
;
; manque SWAP ici ????
;  ou sinon on peut gerer ca en word !!!!
;
	muls	d0,d1
	asl.l	#6,d1
	swap	d1
	sub	d1,d0							
coso_novol:
	bra	L628
	;ENDC

	;IFEQ	CUTMUS
;LCA:

	;IFEQ	DIGIT
	;MOVE.L	L934(PC),A0
	;CMP.L	#'DIGI',(A0)
	;bne.s	.nodigit
	;clr.b	$fffffa19.w

	;IFEQ	SYSTEM
	;move	sr,D1
	;move	#$2700,sr

	;lea	pushreg(pc),a1
	;move.l	(a1)+,basemfp+$34.w
	;move.b	(a1)+,$fffffa17.w
	;move.b	(a1)+,$fffffa07.w
	;move.b	(a1)+,$fffffa13.w
	;move.b	(a1)+,d0

;MC	clr.b	$fffffa19.w
	;move.b	(a1)+,$fffffa1f.w
	;move.b	d0,$fffffa19.w

	;BCLR	#5,$FFFFFA0f.W
	;BCLR	#5,$FFFFFA0b.W

	;move	D1,sr
	;ENDC
;.nodigit:
	;ENDC

;ZEROSND:
	;clr.B	$22(A6)
	;clr.B	$26(A6)
	;clr.B	$2A(A6)
	;MOVEM.L	$1C(A6),D0-D3
	;MOVEM.L	D0-D3,$FFFF8800.W
	;RTS
	;ENDC

coso_escape_ENV1:
	PEA			(A0)										; 00C0364E 4850                     PEA.L (A0)
	MOVE.L	 	registres_virtuels_YM_c04f4c(PC),A0			; 00C03650 207a 18fa                MOVEA.L (PC,$18fa) == $00c04f4c [00c0663e],A0
	MOVE.B 		(A1)+,$0B(A0)								; 00C03654 1159 000b                MOVE.B (A1)+ [fd],(A0,$000b) == $00c051c9 [30]
	MOVE.B 		#$00,$0C(A0)								; 00C03658 117c 0000 000c           MOVE.B #$00,(A0,$000c) == $00c051ca [3c]
	MOVE.B 		#$0a,$0D(A0)								; 00C0365E 117c 000a 000d           MOVE.B #$0a,(A0,$000d) == $00c051cb [ac]
	MOVE.L 		(A7)+,A0									; 00C03664 205f                     MOVEA.L (A7)+ [00c0013e],A0
	JMP 		coso_back_from_coso_escape_ENV1			; 00C03666 4ef9 00c1 73f4           JMP $00c173f4

;coso_escape_DIGIT2:
;	MOVEM.L D0-D7/A0-A6,-(A7)							; 00C0360E 48e7 fffe                MOVEM.L D0-D7/A0-A6,-(A7)
;	MOVEA.L (PC,$038e) == $00c039a2 [00c34128],A1		; 00C03612 227a 038e                MOVEA.L (PC,$038e) == $00c039a2 [00c34128],A1
; 00C03616 0240 00ff                AND.W #$00ff,D0
; 00C0361A 3340 000c                MOVE.W D0,(A1,$000c) == $0003ee26 [3500]
; 00C0361E 08e9 0002 001c           BSET.B #$0002,(A1,$001c) == $0003ee36 [07]
; 00C03624 4cd7 7fff                MOVEM.L (A7),D0-D7/A0-A6
; A5=table des pointeurs de digidrums	00C03628 4bfa fe5c                LEA.L (PC,$fe5c) == $00c03486,A5
; 00C0362C e748                     LSL.W #$03,D0
; 00C0362E dac0                     ADDA.W D0,A5
; 00C03630 205d                     MOVEA.L (A5)+ [000b7896],A0
; 00C03632 241d                     MOVE.L (A5)+ [000b7896],D2
; 00C03634 323c 0100                MOVE.W #$0100,D1
; 00C03638 1219                     MOVE.B (A1)+ [fd],D1
; 00C0363A 7002                     MOVEQ #$02,D0
; 00C0363C 6100 2e1e                BSR.W #$2e1e == $00c0645c
;	MOVEM.L (A7)+,D0-D7/A0-A6							; 00C03640 4cdf 7fff                MOVEM.L (A7)+,D0-D7/A0-A6

; 00C03644 5249                     ADDAQ.W #$01,A1
; 00C03646 5646                     ADDQ.W #$03,D6
; 00C03648 3146 0016                MOVE.W D6,(A0,$0016) == $00c051d4 [2a6c]
;	rts													; 00C0364C 4e75                     RTS 


	


INITMUSIC:
;
; init musique
;
; entr‚e :
;	A0=pointe sur le texte 'COSO'
;	D0=num‚ro de la musique … jouer
;
	LEA	PSGREG(PC),A6

	subq	#1,d0
	TST.B	flagdigit-PSGREG(A6)
	BEQ.S	coso_NODIG
	CLR.B	flagdigit-PSGREG(A6)
	NOP					; clr.b	$fffffa19.w
coso_NODIG:

	CMP.L	#'DIGI',(A0)
	BNE.S	coso_PASDIGIT

	NOP					; MOVE	SR,D1
	NOP					; MOVE	#$2700,SR

	LEA		L51(PC),A1
	MOVE.L	A1,MODIF1+2-PSGREG(A6)
	LEA		flagdigit(PC),A1
	MOVE.L	A1,MODIF2+2-PSGREG(A6)

	;nop					;lea	pushreg(pc),a1
	;nop					;move.l	basemfp+$34.w,(a1)+
	;nop					;move.b	$fffffa17.w,(a1)+
	;nop					;move.b	$fffffa07.w,(a1)+
	;nop					;move.b	$fffffa13.w,(a1)+
	;nop					;move.b	$fffffa19.w,(a1)+
	;nop					;clr.b	$fffffa19.w
	;nop					;move.b	$fffffa1f.w,(a1)+

	;nop					;MOVE.B	#$40,$FFFFFA17.W	;AEI
	
;	BSET	#5,$FFFFFA07.W
;	BSET	#5,$FFFFFA13.W
	;nop					;OR.B	#1<<5,$FFFFFA07.W
	;nop					;OR.B	#1<<5,$FFFFFA13.W

;	BCLR	#5,$FFFFFA0f.W
;	BCLR	#5,$FFFFFA0b.W
;	OR.B	#$FF-1<<5,$FFFFFA0F.W
;	OR.B	#$FF-1<<5,$FFFFFA0B.W
	;nop					;MOVE.B	#$FF-1<<5,$FFFFFA0F.W
	;nop					;MOVE.B	#$FF-1<<5,$FFFFFA0B.W

	;nop					;CLR.B	$FFFFFA19.W
	
	LEA	REPLAY(PC),A1
	
	;nop					;MOVE.L	A1,basemfp+$34.W
;	MOVE.L	#$707FFFF,$FFFF8800.W
	;nop					;MOVE.B	#$A,$FFFF8800.W
	;nop					;MOVE	D1,SR

coso_PASDIGIT:
	cmp.l	#'MMME',32(a0)
	seq		mmme-PSGREG(a6)

	MOVE.L	A0,L934-PSGREG(A6)
	MOVE.L	$10(A0),A3
	ADD.L	A0,A3
	MOVE.L	$14(A0),A1
	ADD.L	A0,A1
;	ADD	D0,D0
;	ADD	D0,A1
;	ADD	D0,D0
	MULU	#6,D0
	ADD	D0,A1
	MOVEQ	#$C,D0
	MULU	(A1)+,D0	;PREMIER PATTERN
	MOVEQ	#$C,D2
	MULU	(A1)+,D2	;DERNIER PATTERN
	SUB	D0,D2

	ADD.L	D0,A3

	MOVE.B	1(A1),L810-PSGREG(A6)

	MOVEQ	#0,D0
	LEA	voice0(PC),A2
;
; REGISTRES UTILISES :
;
; D0=COMPTEUR VOIX 0-2
; D1=SCRATCH
; D2=PATTERN FIN
; A0={L934}
; A1=SCRATCH
; A2=VOICEX
; A3=PATTERN DEPART
; A6=BASE VARIABLES
;
L658:
	LEA	L7C6(PC),A1
	MOVE.L	A1,offa(A2)
	MOVE.L	A1,off12(A2)
	MOVEQ	#1,D1
	MOVE.B	D1,off17(A2)	;1
	MOVE.B	D1,off18(A2)	;1

	MOVE.B	d0,off21(A2)
	move.l	A3,off0(A2)
	move	D2,off34(A2)
	MOVE.B	#2,off2a(A2)

	moveq	#0,D1
	.if		coso_OLD=1
	MOVE	D1,off4(a2)
	.endif
	.if		coso_OLD=0
	move	#$c,off4(A2)
	.endif

	MOVE	D1,offe(A2)
	MOVE.B	D1,off2d(A2)
	MOVE.B	D1,off8(A2)
	MOVE.B	D1,off9(A2)
	MOVE	D1,off30(A2)
	MOVE.B	D1,off19(A2)
	MOVE.B	D1,off1a(A2)
	MOVE.B	D1,off1b(A2)
	MOVE.B	D1,off1c(A2)
	MOVE.B	D1,off1d(A2)
	MOVE.B	D1,off1e(A2)
	MOVE.B	D1,off1f(A2)
	MOVE.L	D1,off38(A2)
	MOVE.B	D1,off26(A2)
	MOVE.B	D1,off27(A2)
	MOVE.B	D1,off2b(A2)

	move.b	(A3)+,D1
	ADD	D1,D1

	MOVE.L	A0,A1
	ADD	$C+2(A1),D1
	ADD	(A1,D1.W),A1

	MOVE.L	A1,off22(A2)
	move.b	(A3)+,off2c(A2)
	move.b	(A3)+,off16(A2)
	moveq	#$10,D1
	add.B	(A3)+,D1
	bcs.s	L712
	moveq	#0,D1
L712:
	MOVE.B	D1,off28(A2)
	lea	off3c(A2),A2
	ADDQ	#4,D2
	addq	#1,d0
	cmp	#3,d0
	blo	L658

	MOVE.B	#1,L80E-PSGREG(A6)
	RTS			;ou BRA ZEROSND


REPLAY:
L50:
	MOVE.B	0.L,$FFFF8802.W
L51	EQU	L50+2
	BMI.S	L52
MODIF1:
	ADDQ.L	#1,0.L		;L51
	RTE
	
	
L52:
MODIF2:	
	clr.b	0.L		;flagdigit
	clr.b	$fffffa19.w
	RTE

	;.data

L7C6:	DC.B	1,0,0,0,0,0,0,$E1
	even
	
PSGREG:	DC.W	0,0,$101,0
	DC.W	$202,0,$303,0
	DC.W	$404,0,$505,0
	DC.W	$606,0,$707,$FFFF
	DC.W	$808
	DC.W	0,$909,0
	DC.W	$A0A,0
	even
	
L94E:	DC.W	$EEE,$E17,$D4D,$C8E
	DC.W	$BD9,$B2F,$A8E,$9F7
	DC.W	$967,$8E0,$861,$7E8
	DC.W	$777,$70B,$6A6,$647
	DC.W	$5EC,$597,$547,$4FB
	DC.W	$4B3,$470,$430,$3F4
	DC.W	$3BB,$385,$353,$323
	DC.W	$2F6,$2CB,$2A3,$27D
	DC.W	$259,$238,$218,$1FA
	DC.W	$1DD,$1C2,$1A9,$191
	DC.W	$17B,$165,$151,$13E
	DC.W	$12C,$11C,$10C,$FD
	DC.W	$EE,$E1,$D4,$C8
	DC.W	$BD,$B2,$A8,$9F
	DC.W	$96,$8E,$86,$7E
	DC.W	$77,$70,$6A,$64
	DC.W	$5E,$59,$54,$4F
	DC.W	$4B,$47,$43,$3F
	DC.W	$3B,$38,$35,$32
	DC.W	$2F,$2C,$2A,$27
	DC.W	$25,$23,$21,$1F
	DC.W	$1D,$1C,$1A,$19
	DC.W	$17,$16,$15,$13
	DC.W	$12,$11,$10,$F
L80E:	DC.B	4
L810:	DC.B	4
BLOQUEMUS:DC.B	-1
;L813:	DC.B	0
	EVEN

	;.bss
	
voice0:	
	ds.B	off3c
voice1:	
	ds.B	off3c
voice2:	
	ds.B	off3c
L934:	ds.l	1

;	IFEQ	MONOCHROM
;DIVISEUR_VBL:DC.W	0;
;	ENDC

;	IFEQ	SYSTEM+DIGIT+CUTMUS
;pushreg:ds.b	9
;	ENDC

mmme:	dc.b	0
flagdigit:
			ds.b	0
;	IFEQ	EQUALISEUR
;	LIST
BOUCLE:	DC.B	0
;	NOLIST
;	ENDC
	even

MUSIC:
;	INCBIN	TUR4.PAK
	INCBIN	"C:/Jaguar/COSO/fichiers mus/COSO/airball.mus"
	even
	
registres_virtuels_YM_c04f4c:
	ds.b				11+3
	even
