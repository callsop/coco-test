
**************************************************************************
* common finish and print results for I1, I2
*
* Craig Allsop - 2025/05/20
**************************************************************************
finish	ldy	oldirq
	sty	$10d
	bsr	cleartop
	ldu	#escreen-2
	bsr	addchk
	std	result
	ldy	#results
	ldx	,y++
	bsr	print
	bsr	printhexd
	rts