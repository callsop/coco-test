#!/bin/bash

function fix_tabs () {
	echo Processing... $1
	expand $1 > $1.1
	cp $1.1 $1
	rm $1.1
}

export -f fix_tabs
ls -1 *.asm | xargs -n1 bash -c 'fix_tabs "$@"' _

