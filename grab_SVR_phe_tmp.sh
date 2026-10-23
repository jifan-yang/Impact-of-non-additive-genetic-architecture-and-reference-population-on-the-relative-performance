#!/bin/sh
#SBATCH --time=0-7
#SBATCH --mem=4000
#SBATCH --cpus-per-task=1

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

cd ${scenario}


for dir in 2000 10000
do
rm SVR_${dir}_${scenario}_phe.txt

for i in $(seq -f "%03g" 1 20)
do

grep "predicted value and TBV of test dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp1
grep "predicted value and GV of test dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp2
grep "predicted value and phenotype of test dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp3
grep "predicted value and TBV of training dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp4
grep "predicted value and GV of training dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp5
grep "predicted value and Phenotype of training dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp6
grep "The bias of ebv in test dataset is" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp7

grep "MSE between predicted value and TBV in test dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp8
grep "MSE between predicted value and GV in test dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp9
grep "MSE between predicted value and phenotype in test dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp10
grep "MSE between predicted value and TBV in training dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp11
grep "MSE between predicted value and GV in training dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp12
grep "MSE between predicted value and phenotype in training dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp13

grep "correlation coefficient between predicted value and BV residual of test dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp14
grep "correlation coefficient between predicted value and GV residual of test dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp15

grep "correlation coefficient between predicted value and BV residual of training dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp16
grep "correlation coefficient between predicted value and GV residual of training dataset" -A 0 ${i}/${dir}/SVR_phe/output.txt | awk '{print $NF}' >> tmp17


done

paste tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 \
      tmp8 tmp9 tmp10 tmp11 tmp12 tmp13 \
      tmp14 tmp15 tmp16 tmp17 >> SVR_${dir}_${scenario}_phe.txt

rm tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 tmp8 tmp9 tmp10 tmp11 tmp12 tmp13 tmp14 tmp15 tmp16 tmp17 

done

cd ../
done