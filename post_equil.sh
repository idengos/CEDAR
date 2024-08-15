#!/bin/bash

export PATH=$PATH:/home/groups/CEDAR/tools/gromacs-2018_noGPU/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/groups/CEDAR/tools/gromacs-2018_noGPU/lib64

dir=`pwd`

for i in PSM
do
    for j in P2G D2G L2G S2G
    do
      	curr=$dir/$i/$j
        if [ ! -f $curr/prod.gro ]
        then
            echo $curr
	    cd $curr
            gmx editconf -f equil.gro -o equil_smaller.gro -box 6.00083 6.00083 8.7
            gmx grompp -f ../../Inputs/prod.mdp -p system.top -c equil_smaller.gro -o prod.tpr -r equil_smaller.gro -maxwarn 1
	    cd $dir
        fi
    done
done
