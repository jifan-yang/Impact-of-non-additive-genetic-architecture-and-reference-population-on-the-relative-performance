#!/bin/sh
#SBATCH --time=0-01:00:00
#SBATCH --mem=8000
#SBATCH --cpus-per-task=1

awk '{print$3}' GBLUP.sln > ebv.txt
sed '1d' ebv.txt > temp_file && mv temp_file ebv.txt
sed '1d' ebv.txt > temp_file && mv temp_file ebv.txt


tail -500 ebv.txt > ebv_test.txt
head -n -500 ebv.txt > ebv_train.txt


paste ebv_test.txt gv_young.txt > com_gv_young.txt

paste ebv_test.txt pheno_young.txt > com_pheno_young.txt

paste ebv_train.txt gv_ref.txt > com_gv_ref.txt

paste ebv_train.txt pheno.txt > com_pheno_ref.txt

paste pheno.txt gv_ref.txt > com_gvpheno_ref.txt

echo " The correlation between ebv and TBV in generation 16 is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_young.txt

echo " The correlation between ebv and phenotype in generation 16 is"
awk -f /home/WUR/yang110/files/correlation.awk com_pheno_young.txt

echo " The correlation between ebv and TBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_ref.txt

echo " The correlation between ebv and phenotype in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_pheno_ref.txt

echo " The correlation between TBV and phenotype in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_gvpheno_ref.txt

echo " The bias of ebv in generation 16 is"
awk -f /home/WUR/yang110/files/regression.awk com_gv_young.txt
