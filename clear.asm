**************************************************************************
* clear screen
*
* Craig Allsop - 2025/05/20
**************************************************************************


cleartop
	pshs	a,b,x
	ldd	#$2020
	ldx	#screen
.loop   std	,x++
	cmpx	#screen+8*32
	bne	.loop
	puls	a,b,x,pc

clear   pshs	a,b,x
	ldd	#$2020
	ldx	#screen
.loop   std	,x++
	cmpx	#escreen
	bne	.loop
	puls	a,b,x,pc

