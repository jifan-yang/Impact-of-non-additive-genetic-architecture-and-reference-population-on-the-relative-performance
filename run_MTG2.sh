#!/bin/sh
#SBATCH --time=0-01:00:00
#SBATCH --mem=7000
#SBATCH --cpus-per-task=1

# ml groups

# ml SHARED/calc_grm/b202409

# calc_grm  


awk '1; END {for(i=1; i<=500; i++) print "NA"}' pheno.txt > pheno_NA.txt
awk '{print "1", NR, $0}' pheno_NA.txt > phe.dat
awk '{print $1, $2, "0", "0", "0", "NA"}' phe.dat > ID.fam
/lustre/scratch/WUR/ABGC/yang110/MTG2/mtg2 -p ID.fam -d phe.dat -g G.grm -conv 0.00001 -thread 1 -out MTG2_Variances.out -mod 1 -bv test.bv



awk '{print$2}' test.bv > ebv.txt
sed '1d' ebv.txt > temp_file && mv temp_file ebv.txt

tail -500 ebv.txt > ebv_test.txt
head -n -500 ebv.txt > ebv_train.txt

#####
paste ebv_test.txt bv_young.txt > com_bv_young.txt
paste ebv_test.txt gv_young.txt > com_gv_young.txt
paste ebv_test.txt pheno_young.txt > com_pheno_young.txt

#####
paste ebv_train.txt bv_ref.txt > com_bv_ref.txt
paste ebv_train.txt gv_ref.txt > com_gv_ref.txt
paste ebv_train.txt pheno.txt > com_pheno_ref.txt

#####
paste pheno.txt bv_ref.txt > com_bvpheno_ref.txt
paste pheno.txt gv_ref.txt > com_gvpheno_ref.txt

######
echo " The correlation between ebv and TBV in generation 16 is"
awk -f /home/WUR/yang110/files/correlation.awk com_bv_young.txt

echo " The correlation between ebv and GV in generation 16 is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_young.txt

echo " The correlation between ebv and phenotype in generation 16 is"
awk -f /home/WUR/yang110/files/correlation.awk com_pheno_young.txt

######
echo " The correlation between ebv and TBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_bv_ref.txt

echo " The correlation between ebv and GV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_ref.txt

echo " The correlation between ebv and phenotype in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_pheno_ref.txt

#######
echo " The bias of ebv in generation 16 is"
awk -f /home/WUR/yang110/files/regression.awk com_bv_young.txt

#######

echo " MSE between predicted value and TBV in test dataset is"
paste ebv_test.txt bv_young.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between predicted value and GV in test dataset is"
paste ebv_test.txt gv_young.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between predicted value and phenotype in test dataset is"
paste ebv_test.txt pheno_young.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between predicted value and TBV in training dataset is"
paste ebv_train.txt bv_ref.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between predicted value and GV in training dataset is"
paste ebv_train.txt gv_ref.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between predicted value and phenotype in training dataset is"
paste ebv_train.txt pheno.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

##############

paste pheno.txt bv_ref.txt | awk '{print $1 - $2}' > residual_bv_ref.txt

paste pheno_young.txt bv_young.txt | awk '{print $1 - $2}' > residual_bv_young.txt

paste pheno.txt gv_ref.txt | awk '{print $1 - $2}' > residual_gv_ref.txt

paste pheno_young.txt gv_young.txt | awk '{print $1 - $2}' > residual_gv_young.txt


paste bv_ref.txt residual_bv_ref.txt > com_res_bv_ref.txt

paste gv_ref.txt residual_gv_ref.txt > com_res_gv_ref.txt

paste bv_young.txt residual_bv_young.txt > com_res_bv_young.txt

paste gv_young.txt residual_gv_young.txt > com_res_gv_young.txt

paste ebv_train.txt residual_bv_ref.txt > com_res_ebv_bv_ref.txt
paste ebv_train.txt residual_gv_ref.txt > com_res_ebv_gv_ref.txt

paste ebv_test.txt residual_bv_young.txt > com_res_ebv_bv_young.txt
paste ebv_test.txt residual_gv_young.txt > com_res_ebv_gv_young.txt

###############

echo " The correlation between BV residual and EBV in test dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_ebv_bv_young.txt

echo " The correlation between GV residual and EBV in test dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_ebv_gv_young.txt

echo " The correlation between BV residual and TBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_bv_ref.txt

echo " The correlation between GV residual and TBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_gv_ref.txt

echo " The correlation between BV residual and TBV in test dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_bv_young.txt

echo " The correlation between GV residual and TBV in test dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_gv_young.txt

echo " The correlation between BV residual and EBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_ebv_bv_ref.txt

echo " The correlation between GV residual and EBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_ebv_gv_ref.txt

################

echo " The correlation between GV and phenotype in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_gvpheno_ref.txt

echo " The correlation between TBV and phenotype in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_bvpheno_ref.txt

rm com_*.txt
