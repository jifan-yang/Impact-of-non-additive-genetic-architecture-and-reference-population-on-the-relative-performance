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
rm h2_estimated_* 
rm h2_ref_*


for i in $(seq -f "%03g" 1 21)
do
grep "h2" ./${i}/500/MTG2_Variances.out | awk '{print $2}' >> h2_estimated_500.txt
grep "h2" ./${i}/2000/MTG2_Variances.out | awk '{print $2}' >> h2_estimated_2000.txt
grep "h2" ./${i}/10000/MTG2_Variances.out | awk '{print $2}' >> h2_estimated_10000.txt
grep "h2" ./${i}/50000/MTG2_Variances.out | awk '{print $2}' >> h2_estimated_50000.txt

grep "h2_ref" ./${i}/500/variance_component.txt | awk '{print $2}' >> h2_ref_500.txt
grep "h2_ref" ./${i}/2000/variance_component.txt | awk '{print $2}' >> h2_ref_2000.txt
grep "h2_ref" ./${i}/10000/variance_component.txt | awk '{print $2}' >> h2_ref_10000.txt
grep "h2_ref" ./${i}/50000/variance_component.txt | awk '{print $2}' >> h2_ref_50000.txt

done

cd ../
done
