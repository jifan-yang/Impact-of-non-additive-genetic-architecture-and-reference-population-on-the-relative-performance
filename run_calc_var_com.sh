#!/bin/bash
#SBATCH --time=0-01:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=data_processing

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8000
#-----------------------------Environment, Operations and Job steps----

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder

for scenario in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${scenario}


for i in $(seq -f "%03g" 1 21)
do
cd ${i}


for dir in 500 2000 10000 50000; do 
cd ${dir}

paste pheno.txt gv_ref.txt | awk '{print $1 - $2}' > residual_ref.txt
paste pheno_young.txt gv_young.txt | awk '{print $1 - $2}' > residual_young.txt
cp $basefolder/scripts/var_com_calc.py .
python var_com_calc.py > variance_component.txt
cd ../
done

cd ../
done

cd ../
done










