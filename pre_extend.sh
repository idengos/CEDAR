#!/bin/bash

dir=`pwd`

for i in POPC
do
    for j in P2G D2G L2G S2G
    do
	curr=$dir/$i/$j
	cd $curr
	gmx convert-tpr -s extend.tpr -nsteps 500000000 -o extend.tpr 
	cd $dir
    done
done


