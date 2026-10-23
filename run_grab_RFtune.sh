#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=RF_tuning

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=9000
#-----------------------------Environment, Operations and Job steps----


basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder


#for scenario in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5

for scenario in \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 
do
cd ${scenario}/021
rm merged_tuneRF_results.txt

#for dir in 1000 2000 10000 50000

for dir in 2000 10000
do
cd ${dir}
rm tune_results.txt

while read -r col1 col2 col3 col4; do

folder="RF_${col1}_${col2}_${col3}_${col4}"

grep "predicted value and GV of test dataset" -A 0 ${folder}/output.txt | awk '{print $NF}' >> tune_results.txt

done < $basefolder/scripts/RF_hyperpara.txt

cd ../
done
#paste 1000/tune_results.txt 2000/tune_results.txt 10000/tune_results.txt 50000/tune_results.txt > merged_tuneRF_results.txt
paste 2000/tune_results.txt 10000/tune_results.txt > merged_tuneRF_results.txt
cd ../../
done