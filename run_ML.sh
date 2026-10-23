#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=SVR_analysis

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=7000
#-----------------------------Environment, Operations and Job steps----

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd "$basefolder/$simfolder" 


for qtl_h2 in \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5
do
cd "${qtl_h2}" 


for i in $(seq -f "%03g" 1 20)
do
cd "${i}" 

    for dir in 2000 10000
    do
      cd "${dir}" 

      # SVR 
      mkdir -p SVR_phe
      cd SVR_phe 

      ln -sf "$basefolder/scripts/ML/run_python_SVR_${dir}.sh"
      ln -sf "$basefolder/scripts/ML/myscript_SVR_${qtl_h2}_${dir}.py"

      sbatch "run_python_SVR_${dir}.sh"

      cd ../

      # RF 
      mkdir -p RF_phe
      cd RF_phe 

      ln -sf "$basefolder/scripts/ML/run_python_RF_${dir}.sh"
      ln -sf "$basefolder/scripts/ML/myscript_RF_${qtl_h2}_${dir}.py"

      sbatch "run_python_RF_${dir}.sh"

      cd ../

      # MLP 
      mkdir -p MLPResNet_phe
      cd MLPResNet_phe 

      ln -sf "$basefolder/scripts/ML/run_python_MLPResNet_${dir}.sh"
      ln -sf "$basefolder/scripts/ML/myscript_MLPResNet_${qtl_h2}_${dir}.py"

      sbatch "run_python_MLPResNet_${dir}.sh"

      cd ../

    cd ../
    done

cd ../
done

cd ../
done