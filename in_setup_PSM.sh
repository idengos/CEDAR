#!/bin/bash

export PATH=$PATH:/home/groups/CEDAR/tools/gromacs-2018_noGPU/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/groups/CEDAR/tools/gromacs-2018_noGPU/lib64

dir=`pwd`
input=$dir/Inputs
ligand=$dir/Ligands

mem=PSM
nmol=1


cd $dir/$mem

for lig in D2G S2G L2G P2G
do

   if [ ! -d $dir/$mem/$lig ]
   then
       mkdir $dir/$mem/$lig
   fi

   cd $dir/$mem/$lig
   curr=`pwd`

   cp $ligand/$lig/start.pdb ./lig.pdb
   cp $ligand/$lig/ligand.itp .
   resname=`grep HETATM $ligand/$lig/start.pdb | head -n 1 | awk '{print $4}'`

   gmx editconf -f ../step5_input.pdb -box 6.00083 6.00083 13 -o bigger_box.pdb
   gmx editconf -f lig.pdb -translate 0 0 8.5 -o moved.pdb

   #remove endmol from bigger_box
   grep -v -e 'ENDMDL' bigger_box.pdb > cleaner_mem.pdb

   #pull out HETATOM from moved.pdb
   grep -v -e 'TITLE' -e 'MODEL' moved.pdb > cleaner_lig.pdb

   # add to step5 and call mem_lig.pdb 
   cat cleaner_mem.pdb cleaner_lig.pdb > mem_lig.pdb
   gmx editconf -f mem_lig.pdb -o mem_lig.gro

   #add LIG.top to topol.top
   sed  '/forcefield.itp/a #include "ligand.itp"' ../topol.top > system.top
   cp -r ../toppar .
   echo $resname $nmol >> system.top
   
    if [ ! -f minimize.gro ]
    then
	gmx grompp -f $input/em.mdp -p system.top -c mem_lig.gro -o minimize.tpr -maxwarn 1
	gmx mdrun -deffnm minimize -v
    fi
    
    if [ ! -f equil.tpr ]
    then
	gmx grompp -f $input/equil.mdp -p system.top -c minimize.gro -o equil.tpr -maxwarn 1
    fi
	
    if [ -f equil.gro ]
    then
	gmx grompp -f $input/run.mdp -p system.top -c equil.gro -o prod.tpr -maxwarn 1
    fi

    rm -rf *#
    cd $dir

done
