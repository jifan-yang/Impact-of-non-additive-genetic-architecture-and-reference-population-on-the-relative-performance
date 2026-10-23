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


for scenario in \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5
do
cd ${scenario}/021
rm merged_tuneRF_pheno.txt

for dir in 2000 10000
do
cd ${dir}

rm error_log_RF.txt tune_RFresults_pheno.txt

while read -r col1 col2 col3 col4; do
    folder="RF_${col1}_${col2}_${col3}_${col4}"

    if [ -f "${folder}/output.txt" ]; then
        result=$(grep "predicted value and phenotype of test dataset" "${folder}/output.txt" | awk '{print $NF}')
        if [ -z "$result" ]; then
            echo "N/A" >> tune_RFresults_pheno.txt
            echo "No matching content: ${scenario}/021/${dir}/${folder}/output.txt" >> error_log_RF.txt
        else
            echo "$result" >> tune_RFresults_pheno.txt
        fi
    else
        echo "N/A" >> tune_RFresults_pheno.txt
        echo "Missing file: ${scenario}/021/${dir}/${folder}/output.txt" >> error_log_RF.txt
    fi

done < $basefolder/scripts/RF_hyperpara.txt


cd ../
done

paste 2000/tune_RFresults_pheno.txt 10000/tune_RFresults_pheno.txt > merged_tuneRF_pheno.txt

cd ../../
done