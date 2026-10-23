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


for scenario in \
    none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
    low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
    high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
    none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
    none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5
do
cd ${scenario}/021



echo "============================ RF ${scenario} Ref = 2000 ==============================="

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
}' merged_tuneRF_pheno.txt)

echo "Best parameter line: RF $best_line"

read -r col1 col2 col3 col4 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/RF_hyperpara.txt
)

echo "Best parameters:"
echo "$col2 $col3 $col4"

echo "============================ RF ${scenario} Ref = 10000 ==============================="

best_line=$(awk '
$2!="N/A"{
    if(!found || $2>max){
        max=$2
        line=NR
        found=1
    }
}
END{
    print line
}' merged_tuneRF_pheno.txt)

echo "Best parameter line: RF $best_line"

read -r col1 col2 col3 col4 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/RF_hyperpara.txt
)

echo "Best parameters:"
echo "$col2 $col3 $col4"


echo "============================ SVR ${scenario} Ref = 2000 ==============================="


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
}' merged_tuneSVR_pheno.txt)

echo "Best parameter line: SVR $best_line"

read -r col1 col2 col3 col4 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/SVR_hyperpara.txt
)

echo "Best parameters:"
echo "$col1 $col2 $col3 $col4"


echo "============================ SVR ${scenario} Ref = 10000 ==============================="


best_line=$(awk '
$2!="NA" && tolower($2)!="nan" {
    val=$2+0
    if(!found || val>max){
        max=val
        line=NR
        found=1
    }
}
END{
    print line
}' merged_tuneSVR_pheno.txt)

echo "Best parameter line: SVR $best_line"

read -r col1 col2 col3 col4 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/SVR_hyperpara.txt
)

echo "Best parameters:"
echo "$col1 $col2 $col3 $col4"




echo "============================ MLP ${scenario} Ref = 2000 ==============================="

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
}' merged_tuneMLPResNet_pheno.txt)

echo "Best parameter line: MLPResNet $best_line"

read -r col1 col2 col3 col4 col5 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/MLPResNet/MLPResNet_hyperpara.txt
)

echo "Best parameters:"
echo "$col1 $col2 $col3 $col4 $col5"


echo "============================ MLP ${scenario} Ref = 10000 ==============================="

best_line=$(awk '
$2!="N/A"{
    val=$2+0
    if(!found || val>max){
        max=val
        line=NR
        found=1
    }
}
END{
    print line
}' merged_tuneMLPResNet_pheno.txt)

echo "Best parameter line: MLPResNet $best_line"

read -r col1 col2 col3 col4 col5 < <(
    sed -n "${best_line}p" \
    $basefolder/scripts/MLPResNet/MLPResNet_hyperpara.txt
)

echo "Best parameters:"
echo "$col1 $col2 $col3 $col4 $col5"


cd ../../
done

