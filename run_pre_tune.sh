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

#########

cd 021

for dir in 1000 2000 10000 50000
do


train=$(( dir * 80 / 100 )) 
val=$(( dir * 20 / 100 ))
  
head -n "$train" train_${dir}.csv > trainX_train_${dir}.csv
tail -n "$val" train_${dir}.csv > val_${dir}.csv

done

cd ../



for scenario in \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    low_medium_aa_5000_0.5 low_medium_aa_100_0.5 low_medium_aa_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
    low_high_aa_5000_0.5 low_high_aa_100_0.5 low_high_aa_50_0.5
do
cd ${scenario}/021

for dir in 1000 2000 10000 50000
do
cd ${dir}

ln -s $basefolder/$simfolder/021/trainX_train_${dir}.csv
ln -s $basefolder/$simfolder/021/val_${dir}.csv

mv trainX_train_${dir}.csv trainX_train.csv
mv val_${dir}.csv valX.csv

train=$(( dir * 80 / 100 )) 
val=$(( dir * 20 / 100 ))


head -n "$train" pheno.txt > phe_train.txt
tail -n "$val" pheno.txt > phe_val.txt

head -n "$train" bv_ref.txt > bv_train.txt
tail -n "$val" bv_ref.txt > bv_val.txt

head -n "$train" gv_ref.txt > gv_train.txt
tail -n "$val" gv_ref.txt > gv_val.txt

cd ../
done

cd ../../
done







