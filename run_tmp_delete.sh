#!/bin/bash
#SBATCH --time=0-01:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=data_processing

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1500

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder



for scenario in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${scenario}/002

rm bv_1000_ID.txt geno_all_1000.txt gv_1000_ID.txt ID_ref_1000.txt train_1000.csv pheno_1000_ID.txt

rm -rf 1000
mv 1000new 1000


cd 1000
ln -s $basefolder/$simfolder/002/train_1000.csv
ln -s $basefolder/$simfolder/002/test.csv
mv train_1000.csv trainX.csv

cp ./bv_1000_ID.txt ../

cp ./gv_1000_ID.txt ../
cp ./pheno_1000_ID.txt ../
cp ./ID_ref_1000.txt ../

cd ../

cd ../../
done

