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

for i in $(seq -f "%03g" 1 20)
do

cd "${i}"

for dir in 2000 10000
do

cd "${dir}"

# =====================
# MLPResNet
# =====================

cd MLPResNet_phe

rm -f EGVbias.out

paste ebv_test.txt gv_young.txt > com_gv_young.txt

echo "The bias of egv in generation 16 is" >> EGVbias.out

awk -f /home/WUR/yang110/files/regression.awk \
com_gv_young.txt >> EGVbias.out

rm com_gv_young.txt

cd ..


# =====================
# SVR
# =====================

cd SVR_phe

rm -f EGVbias.out

tail -n +2 prediction.csv | cut -d',' -f2- > ebv_test.txt

ln -sf ../gv_young.txt gv_young.txt

paste ebv_test.txt gv_young.txt > com_gv_young.txt

echo "The bias of egv in generation 16 is" >> EGVbias.out

awk -f /home/WUR/yang110/files/regression.awk \
com_gv_young.txt >> EGVbias.out

rm com_gv_young.txt

cd ..


# =====================
# RF
# =====================

cd RF_phe

rm -f EGVbias.out

tail -n +2 prediction.csv | cut -d',' -f2- > ebv_test.txt

ln -sf ../gv_young.txt gv_young.txt

paste ebv_test.txt gv_young.txt > com_gv_young.txt

echo "The bias of egv in generation 16 is" >> EGVbias.out

awk -f /home/WUR/yang110/files/regression.awk \
com_gv_young.txt >> EGVbias.out

rm com_gv_young.txt

cd ..

cd ..

done

cd ..

done

cd ..

done
