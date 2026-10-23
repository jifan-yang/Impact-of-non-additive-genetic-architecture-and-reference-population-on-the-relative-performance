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


for i in $(seq -f "%03g" 1 21)
do
cd ${i}

awk '$2 == 11' id_gen.txt > all_11.txt
awk '$2 == 12' id_gen.txt > all_12.txt
awk '$2 == 13' id_gen.txt > all_13.txt
awk '$2 == 14' id_gen.txt > all_14.txt
awk '$2 == 15' id_gen.txt > all_15.txt
awk '$2 == 16' id_gen.txt > all_16.txt

awk '{print $1}' all_11.txt > ID_11.txt
awk '{print $1}' all_12.txt > ID_12.txt
awk '{print $1}' all_13.txt > ID_13.txt
awk '{print $1}' all_14.txt > ID_14.txt
awk '{print $1}' all_15.txt > ID_15.txt
awk '{print $1}' all_16.txt > ID_16.txt

shuf -n 200 ID_11.txt > ID_ref.txt
shuf -n 200 ID_12.txt >> ID_ref.txt
shuf -n 200 ID_13.txt >> ID_ref.txt
shuf -n 200 ID_14.txt >> ID_ref.txt
shuf -n 200 ID_15.txt >> ID_ref.txt

sort -n ID_ref.txt > ID_ref_1000.txt
rm ID_ref.txt

rm ID_1*
rm all_*


cd ../
done


for i in $(seq -f "%03g" 1 21)
do
cd ${i}

awk '{prefix = substr($0, 1, 7);rest = substr($0, 8);gsub(/[34]/, "1", rest);print prefix rest}' Currentpop_mrk_qtl_*.txt > genotype1.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_ref_1000.txt genotype1.txt > geno_ref_1000.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_young.txt genotype1.txt > geno_young.txt  

cat geno_ref_1000.txt geno_young.txt > geno_all_1000.txt

cat geno_ref_1000.txt | cut -c8- > geno_ref1000_noID.txt
sed -E 's/(.)/\1,/g' geno_ref1000_noID.txt > train_1000.csv

rm geno_*_noID.txt
rm geno_ref*.txt genotype1.txt geno_young.txt

cd ../
done


for folder in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${folder}


for i in $(seq -f "%03g" 1 21)
do
cd ${i}

for file in $basefolder/$simfolder/${i}/*; do
    ln -s "$file" .
done

for dir in 1000; do 
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_ref_${dir}.txt bv_all.txt > bv_${dir}_ID.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_ref_${dir}.txt gv_all.txt > gv_${dir}_ID.txt

awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_ref_${dir}.txt pheno_all.txt > pheno_${dir}_ID.txt

awk '{print $2}' bv_${dir}_ID.txt > bv_${dir}.txt
awk '{print $2}' gv_${dir}_ID.txt > gv_${dir}.txt
awk '{print $2}' pheno_${dir}_ID.txt > pheno_${dir}.txt

awk '{print NR, $0,"1"}' pheno_${dir}_ID.txt > pheno_${dir}_MiX.txt

mkdir -p ${dir}
cd "$dir"
ln -s ../bv_young.txt
ln -s ../gv_young.txt
ln -s ../pheno_young.txt
mv ../bv_${dir}.txt .
mv ../gv_${dir}.txt .
mv ../pheno_${dir}.txt .
mv ../pheno_${dir}_MiX.txt .

mv bv_${dir}.txt bv_ref.txt
mv gv_${dir}.txt gv_ref.txt
mv pheno_${dir}.txt pheno.txt
mv pheno_${dir}_MiX.txt phenotype.txt

ln -s $basefolder/scripts/h2.py
python h2.py > output.txt
grep "h2" output.txt | awk '{print $2}' > realh2.txt


cd ../
done

cd ../
done

cd ../
done


########## make superlink for ML models

for scenario in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${scenario}

for i in $(seq -f "%03g" 1 21)
do
cd ${i}

for dir in 1000 2000 10000 50000
do
cd ${dir}
ln -s $basefolder/$simfolder/${i}/train_${dir}.csv
ln -s $basefolder/$simfolder/${i}/test.csv
mv train_${dir}.csv trainX.csv

cd ../
done

cd ../
done

cd ../
done
