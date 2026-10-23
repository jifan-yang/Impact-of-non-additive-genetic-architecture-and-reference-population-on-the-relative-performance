#!/bin/sh
#SBATCH --time=0-7
#SBATCH --mem=4000
#SBATCH --cpus-per-task=1

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder

for scenario in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${scenario}
rm G_1000_${scenario}.txt

for i in $(seq -f "%03g" 1 21)
do

latest_slurm=$(ls -t ${i}/1000/slurm-*.out | head -n1)

grep "ebv and TBV in generation 16" -A 1 "$latest_slurm" | tail -n1 > tmp1
grep "ebv and phenotype in generation 16" -A 1 "$latest_slurm" | tail -n1 > tmp2
grep "ebv and TBV in training dataset" -A 1 "$latest_slurm" | tail -n1 > tmp3
grep "ebv and phenotype in training dataset" -A 1 "$latest_slurm" | tail -n1 > tmp4
grep "TBV and phenotype in training dataset" -A 1 "$latest_slurm" | tail -n1 > tmp5
grep "bias of ebv in generation 16" -A 1 "$latest_slurm" | tail -n1 > tmp6

paste tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 >> G_1000_${scenario}.txt
done
rm tmp1 tmp2 tmp3 tmp4 tmp5 tmp6

cd ../
done