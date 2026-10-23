#!/bin/sh
#SBATCH --time=0-7
#SBATCH --mem=4000
#SBATCH --cpus-per-task=1

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation"

cd $basefolder/$simfolder

#for scenario in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5


for scenario in \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 
do

    cd ${scenario}
    rm GBLUPAD_2000_${scenario}.txt
    rm GBLUPAD_10000_${scenario}.txt
    for i in $(seq -f "%03g" 1 20)
    do

        for dir in 2000 10000
        do

            logpath="${i}/${dir}/GBLUP_AD/slurm-*.out"

            grep "ebv and TBV in generation 16" -A 1 $logpath | tail -n1 > tmp1
            grep "The correlation between EGV and GV in generation 16" -A 1 $logpath | tail -n1 > tmp2
            grep "ebv and phenotype in generation 16" -A 1 $logpath | tail -n1 > tmp3
            grep "ebv and TBV in training dataset" -A 1 $logpath | tail -n1 > tmp4
            grep "ebv and GV in training dataset" -A 1 $logpath | tail -n1 > tmp5
            grep "ebv and phenotype in training dataset" -A 1 $logpath | tail -n1 > tmp6
            grep "bias of ebv in generation 16" -A 1 $logpath | tail -n1 > tmp7

            grep "MSE between predicted value and TBV in test dataset is" -A 1 $logpath | tail -n1 > tmp8
            grep "MSE between predicted value and GV in test dataset is" -A 1 $logpath | tail -n1 > tmp9
            grep "MSE between predicted value and phenotype in test dataset is" -A 1 $logpath | tail -n1 > tmp10
            grep "MSE between predicted value and TBV in training dataset is" -A 1 $logpath | tail -n1 > tmp11
            grep "MSE between predicted value and GV in training dataset is" -A 1 $logpath | tail -n1 > tmp12
            grep "MSE between predicted value and phenotype in training dataset is" -A 1 $logpath | tail -n1 > tmp13

            grep "The correlation between BV residual and EBV in test dataset is" -A 1 $logpath | tail -n1 > tmp14
            grep "The correlation between GV residual and EBV in test dataset is" -A 1 $logpath | tail -n1 > tmp15
            grep "The correlation between BV residual and TBV in training dataset is" -A 1 $logpath | tail -n1 > tmp16
            grep "The correlation between GV residual and TBV in training dataset is" -A 1 $logpath | tail -n1 > tmp17
            grep "The correlation between BV residual and TBV in test dataset is" -A 1 $logpath | tail -n1 > tmp18
            grep "The correlation between GV residual and TBV in test dataset is" -A 1 $logpath | tail -n1 > tmp19
            grep "The correlation between BV residual and EBV in training dataset is" -A 1 $logpath | tail -n1 > tmp20
            grep "The correlation between GV residual and EBV in training dataset is" -A 1 $logpath | tail -n1 > tmp21
            grep "The correlation between GV and phenotype in training dataset is" -A 1 $logpath | tail -n1 > tmp22
            grep "The correlation between TBV and phenotype in training dataset is" -A 1 $logpath | tail -n1 > tmp23

            paste tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 \
                  tmp8 tmp9 tmp10 tmp11 tmp12 tmp13 \
                  tmp14 tmp15 tmp16 tmp17 tmp18 tmp19 tmp20 tmp21 tmp22 tmp23 \
                  >> GBLUPAD_${dir}_${scenario}.txt

            rm tmp1 tmp2 tmp3 tmp4 tmp5 tmp6 tmp7 \
               tmp8 tmp9 tmp10 tmp11 tmp12 tmp13 \
               tmp14 tmp15 tmp16 tmp17 tmp18 tmp19 tmp20 tmp21 tmp22 tmp23

        done
    done

    cd ../
done
