#!/bin/bash



dir=`pwd`
input=$dir/Inputs
ligand=$dir/Ligands

mem=POPC


cd $dir/$mem

for LIG in D2G S2G L2G P2G
do

   cd $dir/$mem/$LIG
   curr=`pwd`

   resname=`grep HETATM $ligand/$LIG/start.pdb | head -n 1 | awk '{print $4}'`   

    echo "q" >> index.inp
    echo "System" >> zero.inp
#    if [ ! -f extend.gro ]
#       srun -u -c 8 gmx trjconv -f extend.xtc -s extend.tpr -dump 310130 -o extend.gro
#    fi
	
    gmx make_ndx -f prod.tpr < index.inp

   for i in $(seq 0.2 0.1 4.3)
   do

       if [ ! -d $dir/$mem/$LIG/$i ]
       then
	   mkdir $dir/$mem/$LIG/$i
       fi


       num_dir=$dir/$mem/$LIG/$i
       cd $num_dir
       cp ../system.top system.top
       cp -r ../toppar/ .
       cp ../ligand.itp .




       sed -e "s/YYYYY/$i/g" -e "s/XXXXX/4.2642/g" -e "s/PEP/$resname/g" $input/umbrella.mdp > $num_dir/uprod.mdp
       gmx grompp -f uprod.mdp -p system.top -c ../extend.gro -o uprod.tpr -r ../extend.gro -n ../index.ndx -maxwarn 2

   done
done
cd $dir
done
