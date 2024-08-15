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
      for k in $(seq 0.2 0.1 4.3)
      do

       curr=$dir/$i/$j/$k
       if [ ! -f $curr/uprod.gro ]
       then
	   echo $curr
	   sbatch -A cedar2 -p exacloud -N $nnode --exclusive -t $maxtime --job-name=uprod_$i_$j_$k\
        uprod.sh $curr $nproc $maxhour 
       fi
      done

    done
done

