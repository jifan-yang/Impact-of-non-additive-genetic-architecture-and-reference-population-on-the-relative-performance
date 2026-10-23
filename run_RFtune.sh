#!/bin/bash
#SBATCH --time=01:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=RF_tuning

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=9000
#-----------------------------Environment, Operations and Job steps----


basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder


#for scenario in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5

for scenario in \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 
do
cd ${scenario}/021

# for dir in 1000 2000 10000 50000
for dir in 2000 10000
do
cd ${dir}

while read -r col1 col2 col3 col4; do
    folder="RF_${col1}_${col2}_${col3}_${col4}"
    if [ -d "$folder" ]; then
        echo "foler $folder exist, then skip the line"
        continue
    fi

    mkdir -p "$folder"
    
    sed -e "s/NUM1/${col1}/g" \
        -e "s/NUM2/${col2}/g" \
        -e "s/NUM3/${col3}/g" \
        -e "s/NUM4/${col4}/g" \
        $basefolder/scripts/RF_script.py > "$folder/myscript.py"
    
    echo "make file $folder/myscript.py"
    cd $folder
    ln -s $basefolder/scripts/run_python.sh
    sbatch run_python.sh
    cd ../

done < $basefolder/scripts/RF_hyperpara.txt

cd ../
done

cd ../../
done