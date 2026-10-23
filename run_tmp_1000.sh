#!/bin/bash
#SBATCH --time=1-19:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=data_processing

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=150000



basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder


for folder in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${folder}/002


mkdir -p 1000new
cd 1000new
ln -s ../bv_young.txt
ln -s ../gv_young.txt
ln -s ../pheno_young.txt
ln -s ../bv_all.txt
ln -s ../gv_all.txt
ln -s ../pheno_all.txt

ln -s /lustre/scratch/WUR/ABGC/yang110/simulations/data/r_simulation/002/ID_reference_1000.txt

awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_reference_1000.txt bv_all.txt > bv_1000_ID.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_reference_1000.txt gv_all.txt > gv_1000_ID.txt

awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_reference_1000.txt pheno_all.txt > pheno_1000_ID.txt

awk '{print $2}' bv_1000_ID.txt > bv_1000.txt
awk '{print $2}' gv_1000_ID.txt > gv_1000.txt
awk '{print $2}' pheno_1000_ID.txt > pheno_1000.txt

awk '{print NR, $0,"1"}' pheno_1000_ID.txt > pheno_1000_MiX.txt

mv bv_1000.txt bv_ref.txt
mv gv_1000.txt gv_ref.txt
mv pheno_1000.txt pheno.txt
mv pheno_1000_MiX.txt phenotype.txt

ln -s $basefolder/scripts/h2.py
python h2.py > output.txt
grep "h2" output.txt | awk '{print $2}' > realh2.txt

ln -s $basefolder/$simfolder/002/1000new/G.grm
cp $basefolder/scripts/run_MTG2.sh .
sbatch run_MTG2.sh


cd ../../../
done

