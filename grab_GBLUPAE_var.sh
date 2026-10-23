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
    rm GBLUPAE_2000_var_${scenario}.txt
    rm GBLUPAE_10000_var_${scenario}.txt
    for i in $(seq -f "%03g" 1 20)
    do

        for dir in 2000 10000
        do

            logpath="${i}/${dir}/GBLUP_AE/MTG2_Variances.out"

                        if [ -f "$logpath" ]; then
                            grep '^ *h2' "$logpath" | awk '{print $2}' | sed -n '1p' > tmp1
                            grep '^ *h2' "$logpath" | awk '{print $2}' | sed -n '2p' > tmp2
                        else
                            echo "NA" > tmp1
                            echo "NA" > tmp2

                        fi

            paste tmp1 tmp2 >> GBLUPAE_${dir}_var_${scenario}.txt

            rm tmp1 tmp2 
        done
    done

    cd ../
done
