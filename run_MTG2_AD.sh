#!/bin/sh
#SBATCH --time=0-01:00:00
#SBATCH --mem=7000
#SBATCH --cpus-per-task=1



ln -s ../phe.dat
ln -s ../ID.fam
ln -s ../bv_ref.txt
ln -s ../bv_young.txt
ln -s ../gv_ref.txt
ln -s ../gv_young.txt
ln -s ../pheno.txt
ln -s ../pheno_young.txt

echo "G.grm" > grm_list.txt
echo "D.grm" >> grm_list.txt


/lustre/scratch/WUR/ABGC/yang110/MTG2/mtg2 -p ID.fam -d phe.dat -mg grm_list.txt -conv 0.00001 -thread 1 -out MTG2_Variances.out -mod 1 -bv test.bv

sed '1d' test.bv > test_noID.txt

awk '{print $2}' test_noID.txt > ebv.txt
awk '{print $2+$3}' test_noID.txt > egv.txt

tail -500 ebv.txt > ebv_test.txt
head -n -500 ebv.txt > ebv_train.txt

tail -500 egv.txt > egv_test.txt
head -n -500 egv.txt > egv_train.txt


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


###############################
###############################


paste egv_test.txt bv_young.txt > com_gv_bv_young.txt
paste egv_test.txt gv_young.txt > com_gv_gv_young.txt
paste egv_test.txt pheno_young.txt > com_gv_pheno_young.txt

#####
paste egv_train.txt bv_ref.txt > com_gv_bv_ref.txt
paste egv_train.txt gv_ref.txt > com_gv_gv_ref.txt
paste egv_train.txt pheno.txt > com_gv_pheno_ref.txt


######
echo " The correlation between EGV and TBV in generation 16 is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_bv_young.txt

echo " The correlation between EGV and GV in generation 16 is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_gv_young.txt

echo " The correlation between EGV and phenotype in generation 16 is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_pheno_young.txt

######
echo " The correlation between EGV and TBV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_bv_ref.txt

echo " The correlation between EGV and GV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_gv_ref.txt

echo " The correlation between EGV and phenotype in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_gv_pheno_ref.txt

#######
echo " The bias of EGV in generation 16 is"
awk -f /home/WUR/yang110/files/regression.awk com_gv_gv_young.txt

#######

echo " MSE between EGV and TBV in test dataset is"
paste egv_test.txt bv_young.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between EGV and GV in test dataset is"
paste egv_test.txt gv_young.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between EGV and phenotype in test dataset is"
paste egv_test.txt pheno_young.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between EGV and TBV in training dataset is"
paste egv_train.txt bv_ref.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between EGV and GV in training dataset is"
paste egv_train.txt gv_ref.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

echo " MSE between EGV and phenotype in training dataset is"
paste egv_train.txt pheno.txt | awk '{ err = $1 - $2; sum += err * err } END { print sum / NR }'

##############

paste egv_train.txt residual_bv_ref.txt > com_res_egv_bv_ref.txt
paste egv_train.txt residual_gv_ref.txt > com_res_egv_gv_ref.txt

paste egv_test.txt residual_bv_young.txt > com_res_egv_bv_young.txt
paste egv_test.txt residual_gv_young.txt > com_res_egv_gv_young.txt

###############

echo " The correlation between BV residual and EGV in test dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_egv_bv_young.txt

echo " The correlation between GV residual and EGV in test dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_egv_gv_young.txt


echo " The correlation between BV residual and EGV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_egv_bv_ref.txt

echo " The correlation between GV residual and EGV in training dataset is"
awk -f /home/WUR/yang110/files/correlation.awk com_res_egv_gv_ref.txt

rm com_*.txt

