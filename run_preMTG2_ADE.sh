#!/bin/bash
#SBATCH --time=0-06:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=preMTG2_ADE

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1500
#-----------------------------Environment, Operations and Job steps----

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation"

cd $basefolder/$simfolder

# for folder in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 

for folder in \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 
do
cd ${folder}


for i in $(seq -f "%03g" 1 20)
do

cd ${i}

# for dir in 500 2000 10000 50000; do 

for dir in 2000 10000; do 
cd ${dir}

mkdir -p GBLUP_ADE
cd GBLUP_ADE

ln -s $basefolder/$simfolder/${i}/${dir}/G.grm
ln -s $basefolder/$simfolder/${i}/${dir}/D.grm
ln -s $basefolder/$simfolder/${i}/${dir}/E.grm

cp $basefolder/scripts/run_MTG2_ADE.sh .
sbatch run_MTG2_ADE.sh
cd ../

cd ../
done

cd ../
done

cd ../
done

