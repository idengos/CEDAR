#!/bin/bash

##############################################
# Time limits
maxhour=36 # hours
maxtime=`echo $maxhour | awk '{print $1*60}'`
##############################################

######################
# Processor allocation
nnode=1
nproc=`echo $nnode | awk '{print $1*24}'`
######################


dir=`pwd`

for i in POPC
do
    for j in P2G D2G L2G S2G
    do
	curr=$dir/$i/$j
	if [ ! -f $curr/extend.gro ]
	then
	    echo $curr
	    sbatch -A cedar2 -p exacloud -N $nnode --exclusive -t $maxtime --job-name=$j\
  extend.sh $curr $nproc $maxhour 
	fi
    done
done

