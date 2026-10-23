#!/bin/sh
#SBATCH --time=0-7
#SBATCH --mem=4000
#SBATCH --cpus-per-task=1

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder

for scenario in 5000_0.5 5000_0.1 100_0.5 100_0.1 50_0.5 50_0.1
do
cd none_none_none_${scenario}

######## RF

for dir in 1000 2000 10000 50000
do

for i in $(seq -f "%03g" 1 20)
do


grep "MSE between predicted value and phenotype in training" -A 1 ${i}/${dir}/RF/MSE_cor.txt | tail -n1 >> tmp1

grep "MSE between predicted value and phenotype in test" -A 1 ${i}/${dir}/RF/MSE_cor.txt | tail -n1 >> tmp2

grep "MSE between predicted value and TBV in training" -A 1 ${i}/${dir}/RF/MSE_cor.txt | tail -n1 >> tmp3

grep "MSE between predicted value and TBV in test" -A 1 ${i}/${dir}/RF/MSE_cor.txt | tail -n1 >> tmp4

grep "correlation between residual and TBV in training" -A 1 ${i}/${dir}/RF/MSE_cor.txt | tail -n1 >> tmp5

grep "correlation between residual and EBV in training" -A 1 ${i}/${dir}/RF/MSE_cor.txt | tail -n1 >> tmp6

grep "correlation between residual and EBV in test" -A 1 ${i}/${dir}/RF/MSE_cor.txt | tail -n1 >> tmp7

done

rm RF_MSE_cor_${scenario}_${dir}.txt
paste tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 >> RF_MSE_cor_${scenario}_${dir}.txt

rm tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7

done

######## SVR

for dir in 1000 2000 10000 50000
do

for i in $(seq -f "%03g" 1 20)
do


grep "MSE between predicted value and phenotype in training" -A 1 ${i}/${dir}/SVR/MSE_cor.txt | tail -n1 >> tmp1

grep "MSE between predicted value and phenotype in test" -A 1 ${i}/${dir}/SVR/MSE_cor.txt | tail -n1 >> tmp2

grep "MSE between predicted value and TBV in training" -A 1 ${i}/${dir}/SVR/MSE_cor.txt | tail -n1 >> tmp3

grep "MSE between predicted value and TBV in test" -A 1 ${i}/${dir}/SVR/MSE_cor.txt | tail -n1 >> tmp4

grep "correlation between residual and TBV in training" -A 1 ${i}/${dir}/SVR/MSE_cor.txt | tail -n1 >> tmp5

grep "correlation between residual and EBV in training" -A 1 ${i}/${dir}/SVR/MSE_cor.txt | tail -n1 >> tmp6

grep "correlation between residual and EBV in test" -A 1 ${i}/${dir}/SVR/MSE_cor.txt | tail -n1 >> tmp7

done

rm SVR_MSE_cor_${scenario}_${dir}.txt
paste tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 >> SVR_MSE_cor_${scenario}_${dir}.txt

rm tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7

done


######## GBLUP

for dir in 1000 2000 10000 50000
do

for i in $(seq -f "%03g" 1 20)
do


grep "MSE between predicted value and phenotype in training" -A 1 ${i}/${dir}/MSE_cor.txt | tail -n1 >> tmp1

grep "MSE between predicted value and phenotype in test" -A 1 ${i}/${dir}/MSE_cor.txt | tail -n1 >> tmp2

grep "MSE between predicted value and TBV in training" -A 1 ${i}/${dir}/MSE_cor.txt | tail -n1 >> tmp3

grep "MSE between predicted value and TBV in test" -A 1 ${i}/${dir}/MSE_cor.txt | tail -n1 >> tmp4

grep "correlation between residual and TBV in training" -A 1 ${i}/${dir}/MSE_cor.txt | tail -n1 >> tmp5

grep "correlation between residual and EBV in training" -A 1 ${i}/${dir}/MSE_cor.txt | tail -n1 >> tmp6

grep "correlation between residual and EBV in test" -A 1 ${i}/${dir}/MSE_cor.txt | tail -n1 >> tmp7

done

rm GBLUP_MSE_cor_${scenario}_${dir}.txt
paste tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 >> GBLUP_MSE_cor_${scenario}_${dir}.txt

rm tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7

done
























cd ../
done