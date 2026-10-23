#!/bin/sh
#SBATCH --time=0-7
#SBATCH --mem=4000
#SBATCH --cpus-per-task=1

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation"

cd $basefolder/$simfolder


for scenario in \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 
do

    cd ${scenario}
    rm GBLUPAD_2000_var_${scenario}.txt
    rm GBLUPAD_10000_var_${scenario}.txt
    for i in $(seq -f "%03g" 1 20)
    do

        for dir in 2000 10000
        do

            logpath="${i}/${dir}/GBLUP_AD/MTG2_Variances.out"

            grep '^ *h2' $logpath | awk '{print $2}' | sed -n '1p' > tmp1
            grep '^ *h2'  $logpath | awk '{print $2}' | sed -n '2p' > tmp2
            grep '^ *h2' $logpath | awk '{print $2}' | sed -n '3p' > tmp3

            paste tmp1 tmp2 tmp3 >> GBLUPAD_${dir}_var_${scenario}.txt

            rm tmp1 tmp2 tmp3 
        done
    done

    cd ../
done
