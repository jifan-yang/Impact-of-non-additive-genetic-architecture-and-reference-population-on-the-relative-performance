#!/bin/bash
#SBATCH --time=0-06:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=sample_markers

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1500
#-----------------------------Environment, Operations and Job steps----

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation"

cd $basefolder/$simfolder

for folder in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${folder}


for i in $(seq -f "%03g" 1 21)
do

cd ${i}

for dir in 1000; do 
cd ${dir}
ln -s $basefolder/$simfolder/${i}/${dir}/G.grm
cp $basefolder/scripts/run_MTG2.sh .
sbatch run_MTG2.sh

cd ../
done

cd ../
done

cd ../
done
