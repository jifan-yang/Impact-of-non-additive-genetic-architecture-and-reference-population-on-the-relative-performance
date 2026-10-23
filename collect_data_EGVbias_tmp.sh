#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=RF_tuning

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4000
#-----------------------------Environment, Operations and Job steps----

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations/data/r_simulation"

cd $basefolder

for scenario in \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 
do

cd ${scenario}

for model in RF SVR MLPResNet
do

for dir in 2000 10000
do

file="${model}_${dir}_${scenario}_EGVbias_phe.txt"

values=($(awk '{print $1}' "$file"))



count=${#values[@]}
if [ "$count" -ne 20 ]; then
    echo "Error: not 20 replicates"
    exit 1
fi


clean_name="${file%.txt}"
clean_name="${clean_name%_EGVbias_phe}"
clean_name="${clean_name%_0.5}"

printf "%s = [" "$clean_name"
for ((i=0; i<20; i++)); do
    val=$(printf "%.3f" "${values[$i]}")
    if [ $i -lt 19 ]; then
        printf "%s, " "$val"
    else
        printf "%s" "$val"
    fi
done

printf "]\n"

done
done
cd ../
done