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

for i in $(seq -f "%03g" 1 20)
do

cd ${i}

for dir in 1000 2000 10000 50000
do

cd ${dir}
ln -sf $basefolder/scripts/run_MSE_L.sh
sbatch run_MSE_L.sh

cd RF
ln -sf $basefolder/scripts/run_MSE_ML.sh
sbatch run_MSE_ML.sh

cd ../SVR

ln -sf $basefolder/scripts/run_MSE_ML.sh
sbatch run_MSE_ML.sh

cd ../../
done

cd ../
done

cd ../
done