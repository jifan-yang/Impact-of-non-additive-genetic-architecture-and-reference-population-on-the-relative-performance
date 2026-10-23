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


for i in $(seq -f "%03g" 1 20)
do

cd ${i}

# for dir in 500 2000 10000 50000; do 
for dir in 2000 10000; do 
# mkdir -p ${dir}
# mv geno_all_${dir}.txt ./${dir}

cd ${dir}
# mv geno_all_${dir}.txt genotype.txt
rm calc_grm.inp
cp $basefolder/scripts/calc_grm.inp .
# cp $basefolder/scripts/run_calc_grm.sh .
sbatch run_calc_grm.sh

cd ../
done


cd ../
done
