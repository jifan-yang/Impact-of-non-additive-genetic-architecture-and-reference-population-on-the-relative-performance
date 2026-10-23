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

###### remove merged files
rm merged_tuneSVR_pheno.txt
rm merged_tuneSVR_pheno.txt
rm merged_tuneMLPResNet_pheno.txt

######
for dir in 2000 10000
do
cd ${dir}

###### remove files

rm error_log_SVR.txt tune_SVRresults_pheno.txt
rm error_log_MLP.txt tune_MLPResNetpheno.txt
rm error_log_RF.txt tune_RFresults_pheno.txt

###### RF phenotype

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
        echo "N/A" >> tune_RFresults.txt
        echo "Missing file: ${scenario}/021/${dir}/${folder}/output.txt" >> error_log_RF.txt
    fi

done < $basefolder/scripts/RF_hyperpara.txt



###### SVR phenotype

while read -r col1 col2 col3 col4; do
    folder="SVR_${col1}_${col2}_${col3}_${col4}"

    if [ -f "${folder}/output.txt" ]; then
        result=$(grep "predicted value and phenotype of test dataset" "${folder}/output.txt" | awk '{print $NF}')
        if [ -z "$result" ]; then
            echo "N/A" >> tune_SVRresults_pheno.txt
            echo "No matching content: ${scenario}/021/${dir}/${folder}/output.txt" >> error_log_SVR.txt
        else
            echo "$result" >> tune_SVRresults_pheno.txt
        fi
    else
        echo "N/A" >> tune_SVRresults.txt
        echo "Missing file: ${scenario}/021/${dir}/${folder}/output.txt" >> error_log_SVR.txt
    fi

done < $basefolder/scripts/SVR_hyperpara.txt

####### MLP phenotype

while read -r col1 col2 col3 col4 col5; do
    folder="MLPResNet_${col1}_${col2}_${col3}_${col4}_${col5}"

    if [ -f "${folder}/output.txt" ]; then
        result=$(grep "ebv and phenotype in generation 16" -A 1 ${folder}/slurm-*.out | tail -n1)
        if [ -z "$result" ]; then
            echo "N/A" >> tune_MLPResNetpheno.txt
            echo "No matching content: ${scenario}/021/${dir}/${folder}/slurm-*.out" >> error_log_MLP.txt
        else
            echo "$result" >> tune_MLPResNetpheno.txt
        fi
    else
        echo "N/A" >> tune_MLPResNetpheno.txt
        echo "Missing file: ${scenario}/021/${dir}/${folder}/slurm-*.out" >> error_log_MLP.txt
    fi

done < $basefolder/scripts/MLPResNet/MLPResNet_hyperpara.txt





cd ../
done

paste 2000/tune_RFresults_pheno.txt 10000/tune_RFresults_pheno.txt > merged_tuneRF_pheno.txt
paste 2000/tune_SVRresults_pheno.txt 10000/tune_SVRresults_pheno.txt > merged_tuneSVR_pheno.txt
paste 2000/tune_MLPResNetpheno.txt 10000/tune_MLPResNetpheno.txt > merged_tuneMLPResNet_pheno.txt



cd ../../
done