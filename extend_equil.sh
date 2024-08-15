#!/bin/bash

dir=`pwd`

for i in PSM
do
    for j in P2G D2G L2G S2G
    do
	curr=$dir/$i/$j
	cd $curr
	gmx convert-tpr -s equil.tpr -extend 4000 -o equil.tpr 
	cd $dir
    done
done


