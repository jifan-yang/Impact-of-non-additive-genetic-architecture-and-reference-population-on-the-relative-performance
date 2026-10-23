#!/bin/sh
#SBATCH --time=0-7
#SBATCH --mem=4000
#SBATCH --cpus-per-task=1

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation"

cd "$basefolder/$simfolder"

for scenario in \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5
do

    cd "${scenario}"

    for model in GBLUP_ADE GBLUP_AD GBLUP_AE RF SVR MLPResNet
    do

        rm -f "${model}_2000_${scenario}_EGVbias.txt"
        rm -f "${model}_10000_${scenario}_EGVbias.txt"

        for i in $(seq -f "%03g" 1 20)
        do

            for dir in 2000 10000
            do

                logpath="${i}/${dir}/${model}/EGVbias.out"

                result=$(grep "bias of egv in generation 16" -A 1 "$logpath" 2>/dev/null | tail -n1)

                if [ -z "$result" ]; then
                    echo "NA" >> "${model}_${dir}_${scenario}_EGVbias.txt"
                else
                    echo "$result" >> "${model}_${dir}_${scenario}_EGVbias.txt"
                fi

            done

        done

    done

    cd ..

done