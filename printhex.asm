**************************************************************************
* print a in hex to screen at x
* a = byte to print
* x = screen address (advances)
*
* Craig Allsop - 2025/05/20
**************************************************************************

printhexd
	bsr	printhex
	tfr	b,a
	bsr	printhex
	rts
printhex
	pshs	a,b
	tfr	a,b		split into nibbles
	lsra
	lsra
	lsra
	lsra
	andb	#$f
	addd	#$3030		make ascii
	cmpa	#$3A		adjust for a-f
	blt	.hex1
	suba	#$39
.hex1   cmpb	#$3A
	blt	.hex2
	subb	#$39
.hex2   std	,x++		print it to screen
	puls	a,b,pc

