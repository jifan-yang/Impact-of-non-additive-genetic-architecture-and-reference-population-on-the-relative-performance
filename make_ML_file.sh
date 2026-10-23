#!/bin/bash
#SBATCH --time=01-16:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=sample_markers

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=3000
#-----------------------------Environment, Operations and Job steps----

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"

cd $basefolder/data/r_simulation


for scenario in \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5
do
cd ${scenario}/021


for ref in 2000 10000
do
cd ${ref}


############## For SVR


best_line=$(awk '
$1!="NA" && tolower($1)!="nan" {
    val=$1+0
    if(!found || val>max){
        max=val
        line=NR
        found=1
    }
}
END{
    print line
}' tune_SVRresults_pheno.txt)


echo "Best parameter line: SVR $best_line"

read -r col1 col2 col3 col4 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/SVR_hyperpara.txt
)

echo "Best parameters:"
echo "$col1 $col2 $col3 $col4"

sed \
-e "s/NUM1/${col1}/g" \
-e "s/NUM2/${col2}/g" \
-e "s/NUM3/${col3}/g" \
-e "s/NUM4/${col4}/g" \
$basefolder/scripts/SVR_script1.py \
> $basefolder/scripts/ML/myscript_SVR_${scenario}_${ref}.py

################ For RF


best_line=$(awk '
$1!="N/A"{
    if(!found || $1>max){
        max=$1
        line=NR
        found=1
    }
}
END{
    print line
}' tune_RFresults_pheno.txt)

echo "Best parameter line: RF $best_line"

read -r col1 col2 col3 col4 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/RF_hyperpara.txt
)

echo "Best parameters:"
echo "$col2 $col3 $col4"

sed \
-e "s/NUM2/${col2}/g" \
-e "s/NUM3/${col3}/g" \
-e "s/NUM4/${col4}/g" \
$basefolder/scripts/RF_script1.py \
> $basefolder/scripts/ML/myscript_RF_${scenario}_${ref}.py




############## For MLP-ResNet

best_line=$(awk '
$1!="N/A"{
    val=$1+0
    if(!found || val>max){
        max=val
        line=NR
        found=1
    }
}
END{
    print line
}' tune_MLPResNet_pheno.txt)

echo "Best parameter line: MLPResNet $best_line"

read -r col1 col2 col3 col4 col5 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/MLPResNet_hyperpara.txt
)

echo "Best parameters:"
echo "$col1 $col2 $col3 $col4 $col5"

sed \
-e "s/NUM1/${col1}/g" \
-e "s/NUM2/${col2}/g" \
-e "s/NUM3/${col3}/g" \
-e "s/NUM4/${col4}/g" \
-e "s/NUM5/${col5}/g" \
$basefolder/scripts/MLPResNet_script1.py \
> $basefolder/scripts/ML/myscript_MLPResNet_${scenario}_${ref}.py



cd ../
done


cd ../../
done


