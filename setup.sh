#!/bin/bash

export PATH=$PATH:/home/groups/CEDAR/tools/gromacs-2018_noGPU/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/groups/CEDAR/tools/gromacs-2018_noGPU/lib64

dir=`pwd`
input=$dir/Inputs
struct=$dir/Structures
ligand=$dir/Ligands

lig=S2G

if [ ! -d $dir/$lig ]
then
    mkdir $dir/$lig
fi
cd $dir/$lig
curr=`pwd`

for i in `ls $struct/$lig`
do

    state=`echo $i | sed "s|\.|\ |g" | awk '{print $1}'`

    if [ ! -d $curr/$state ]
    then
	mkdir $curr/$state
    fi
    cd $curr/$state

    resname=`grep HETATM $ligand/$lig/start.pdb | head -n 1 | awk '{print $4}'`


    if [ ! -f receptor.pdb ]
    then
	
	grep -v $resname $struct/$lig/$state.pdb > start.pdb
	
	echo 1 > inp
	echo 1 >> inp
	gmx pdb2gmx -f start.pdb -ignh < inp
	
	gmx editconf -f conf.gro -o receptor.pdb
    fi
	    

    if [ ! -f min.gro ]
    then

	grep $resname $struct/$lig/$state.pdb > ligand.pdb
	
       	echo "del 1-20" > inp
	echo "q" >> inp
	gmx make_ndx -f ligand.pdb -o ligand.ndx < inp
	
	natoms=`grep ATOM ligand.pdb | wc | awk '{print $1}'`
	
	gmx editconf -f $ligand/$lig/LIG.gro -o lig.pdb
	cp $ligand/$lig/start.pdb pseudo.pdb

	echo "del 1-20" > inp
	echo "a 1-" $natoms >> inp
	echo "name 1 Heavy" >> inp
	echo q >> inp
	
	gmx make_ndx -f pseudo.pdb -o pseudo.ndx < inp
	
	echo Heavy > inp
	    
	gmx confrms -f1 ligand.pdb -n1 ligand.ndx -f2 lig.pdb -n2 pseudo.ndx -one -fit -o fit.pdb < inp
	    
	grep ATOM fit.pdb > system.pdb
	grep ATOM receptor.pdb >> system.pdb
	    
	gmx editconf -f system.pdb -o system.gro -d 1.0
	    
	cp $ligand/$lig/ligand.itp .

	sed  '/forcefield.itp/a #include "ligand.itp"' topol.top | sed "s|; Compound        #mols|$resname    1|g" > system.top

	gmx grompp -f $input/em.mdp -p system.top -c system.gro -o min.tpr
	gmx mdrun -deffnm min -v

    fi


    if [ ! -f solvated.gro ]
    then
	cp system.top topol1.top
	gmx solvate -cp min.gro -cs -p topol1.top -o solvated.gro
    fi

    if [ ! -f neutral.gro ]
    then
	
	cp topol1.top topol2.top
	gmx grompp -f $input/em.mdp -p topol1.top -c solvated.gro -o ionize.tpr -maxwarn 1
	echo SOL | gmx genion -s ionize.tpr -p topol2.top -neutral -o neutral.gro -pname NA -nname CL 
	
    fi


    if [ ! -f minimize.gro ]
    then
	gmx grompp -f $input/em.mdp -p topol2.top -c neutral.gro -o minimize.tpr
	gmx mdrun -deffnm minimize -v
    fi
    
    if [ ! -f equil.tpr ]
    then
	gmx grompp -f $input/equil.mdp -p topol2.top -c minimize.gro -o equil.tpr -maxwarn 1
    fi
	
    if [ -f equil.gro ]
    then
	gmx grompp -f $input/run.mdp -p topol2.top -c equil.gro -o prod.tpr -maxwarn 1
    fi


    rm -rf *#
    cd $dir

done

	

