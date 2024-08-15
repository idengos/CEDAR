#!/bin/bash

if [ $# -ne 3 ]
then
    echo "Error in $0 - Invalid Argument Count"
    echo "Usage : $0 dir nproc maxtime"
    exit
fi

module load mpi/openmpi-x86_64


cd $1
nproc=$2
maxtime=$3

if [ -f prod_prev.cpt ]
then

    gmx mdrun -deffnm prod -maxh $maxtime -append -cpi prod_prev.cpt

else

    gmx mdrun -deffnm prod -maxh $maxtime

fi
