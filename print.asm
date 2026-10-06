**************************************************************************
* print - print zero terminated string
* y = string address (modified)
* x = screen address (modified)
*
* Craig Allsop - 2025/05/20
**************************************************************************

        ifndef printmask
printmask equ $40               ; define as 0 (green) or $40 (black) text
        endc


print   pshs    a
.loop   lda     ,y+
        beq     .done
        ora     #$40
        anda    #~printmask
        sta     ,x+
        bra     .loop
.done   puls    a,pc

**************************************************************************
* print_messages - print a bunch of messages
* y = pointer to msgs
* msgs = [ screenpos:word, msg:strz ], 0:word
*
* Craig Allsop - 2026/09/26
**************************************************************************

print_messages_dont_use
.msgs   bsr     print
print_messages
        ldx     ,y++
        bne     .msgs
        rts
