#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=GrabMLP_tuning

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=9000
#-----------------------------Environment, Operations and Job steps----


basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder

# for scenario in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1

for scenario in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5

do
cd ${scenario}/021

rm merged_tuneMLPResNet_tgv.txt


for dir in 2000 10000
do
cd ${dir}

rm tune_MLPResNet_tgv.txt error_log_MLP.txt

while read -r col1 col2 col3 col4 col5; do
    folder="MLPResNet_${col1}_${col2}_${col3}_${col4}_${col5}"

    if [ -f "${folder}/output.txt" ]; then
        result=$(grep "ebv and TBV in generation 16" -A 1 ${folder}/slurm-*.out | tail -n1)
        if [ -z "$result" ]; then
            echo "N/A" >> tune_MLPResNet_tgv.txt
            echo "No matching content: ${scenario}/021/${dir}/${folder}/slurm-*.out" >> error_log_MLP.txt
        else
            echo "$result" >> tune_MLPResNet_tgv.txt
        fi
    else
        echo "N/A" >> tune_MLPResNet_tgv.txt
        echo "Missing file: ${scenario}/021/${dir}/${folder}/slurm-*.out" >> error_log_MLP.txt
    fi

done < $basefolder/scripts/MLPResNet/MLPResNet_hyperpara.txt


cd ../
done

paste 2000/tune_MLPResNet_tgv.txt 10000/tune_MLPResNet_tgv.txt > merged_tuneMLPResNet_tgv.txt
cd ../../
done