#!/bin/bash
#SBATCH --time=0-19:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=data_delete

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=10000



basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder

for scenario in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 \
           none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
           low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
           low_medium_aa_5000_0.5 low_medium_aa_100_0.5 low_medium_aa_50_0.5 \
           high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
           none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
           low_high_aa_5000_0.5 low_high_aa_100_0.5 low_high_aa_50_0.5
do

cd ${scenario}

for i in $(seq -f "%03g" 1 21)
do

mv ./${i}/var_all_*.txt .
mv ./${i}/my_tbvs_Currentpop_*.txt .
mv ./${i}/resvar*.tmp .

rm -r ${i}

done

cd ../
done

###############################

for i in $(seq -f "%03g" 1 21)
do

cd ${i}

rm -rf 1000 2000 10000 50000

rm -f bv_*.txt gv_*.txt ID_*.txt pheno_*.txt slurm*.out t*.csv

cd ../
done