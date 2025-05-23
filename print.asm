
**************************************************************************
* print zero terminated string
* y = string address (modified)
* x = screen address (modified)
*
* Craig Allsop - 2025/05/20
**************************************************************************
print   pshs	a
.loop   lda	,y+
	beq	.done
	anda	#~$40
	sta	,x+
	bra	.loop
.done   puls	a,pc

