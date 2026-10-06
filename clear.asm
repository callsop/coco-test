**************************************************************************
* clear upper 8 rows
*
* Craig Allsop - 2025/05/20
**************************************************************************

        ifndef printmask
printmask equ $40               ; define as 0 (green) or $40 (black) text
        endc

clearbytesmask equ      (printmask*256+printmask)
clearbytes equ  $6060&(~clearbytesmask)

cleartop
        pshs    a,b,x
        ldd     #clearbytes
        ldx     #screen
.loop   std     ,x++
        cmpx    #screen+8*32
        bne     .loop
        puls    a,b,x,pc


**************************************************************************
* clear entire screen
*
* Craig Allsop - 2025/05/20
**************************************************************************

clear   pshs    a,x,u
        ldx     #screen
        ldu     #clearbytes
        clra
.loop   stu     ,x++
        deca
        bne     .loop
        puls    a,x,u,pc

**************************************************************************
* clear entire screen
**************************************************************************

clear_with_u
        pshs    a,x
        ldx     #screen
        clra
.loop   stu     ,x++
        deca
        bne     .loop
        puls    a,x,pc

**************************************************************************
* clear entire screen
**************************************************************************

clear_at_x
        pshs    a,u
        ldu     #clearbytes
        clra
.loop   stu     ,x++
        deca
        bne     .loop
        puls    a,u,pc


