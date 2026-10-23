#!/bin/sh
#SBATCH --time=0-7
#SBATCH --output=MSE_cor.txt  
#SBATCH --mem=4000
#SBATCH --cpus-per-task=1

tail -n +2 prediction.csv | cut -d',' -f2- > ebv_test.txt
tail -n +2 prediction_train.csv | cut -d',' -f2- > ebv_train.txt

ln -sf ../bv_ref.txt
ln -sf ../pheno.txt

ln -sf ../../pheno_young.txt
ln -sf ../../bv_young.txt

echo " MSE between predicted value and phenotype in training dataset is"
paste ebv_train.txt pheno.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between predicted value and phenotype in test dataset is"
paste ebv_test.txt pheno_young.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between predicted value and TBV in training dataset is"
paste ebv_train.txt bv_ref.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between predicted value and TBV in test dataset is"
paste ebv_test.txt bv_young.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'


paste pheno.txt bv_ref.txt | awk '{print $1 - $2}' > residual_ref.txt

paste pheno_young.txt bv_young.txt | awk '{print $1 - $2}' > residual_young.txt

paste bv_ref.txt residual_ref.txt > com_res_bv_ref.txt

paste ebv_train.txt residual_ref.txt > com_res_ebv_ref.txt

paste ebv_test.txt residual_young.txt > com_res_ebv_young.txt

echo " The correlation between residual and TBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_bv_ref.txt

echo " The correlation between residual and EBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_ebv_ref.txt

echo " The correlation between residual and EBV in test dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_ebv_young.txt

rm com_res_bv_ref.txt
rm com_res_ebv_ref.txt
rm com_res_bv_young.txt
