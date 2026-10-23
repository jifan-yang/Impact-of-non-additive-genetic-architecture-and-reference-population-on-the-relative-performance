#!/bin/bash
#SBATCH --time=1-19:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=data_processing

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=150000
#-----------------------------Environment, Operations and Job steps----


basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder


for i in $(seq -f "%03g" 1 21)
do
cd ${i}

####### prepare animal ID 


awk '{print $1, $5}' Currentpop_data_*.txt > id_gen.txt

sed -i '1d' id_gen.txt

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


#### make young ID
shuf -n 500 ID_16.txt | sort -n > ID_young.txt


############ New

gens=(11 12 13 14 15)

# ??????? gen ?????
mkdir -p tmp

# ?????
> ID_ref_50000.txt
> ID_ref_10000.txt
> ID_ref_2000.txt
> ID_ref_1000.txt

for g in "${gens[@]}"; do
    infile="ID_${g}.txt"

    # ?1?:?????10000
    shuf -n 10000 "$infile" > tmp/${g}_L1_10000.txt

    # ?2?:? L1 ?2000
    shuf -n 2000 tmp/${g}_L1_10000.txt > tmp/${g}_L2_2000.txt

    # ?3?:? L2 ?400
    shuf -n 400 tmp/${g}_L2_2000.txt > tmp/${g}_L3_400.txt

    # ?4?:? L3 ?100
    shuf -n 200 tmp/${g}_L3_400.txt > tmp/${g}_L4_200.txt

    # ???????
    cat tmp/${g}_L1_10000.txt >> ID_ref_50000.txt
    cat tmp/${g}_L2_2000.txt  >> ID_ref_10000.txt
    cat tmp/${g}_L3_400.txt   >> ID_ref_2000.txt
    cat tmp/${g}_L4_200.txt   >> ID_ref_1000.txt
done

# ???????????,??????
sort -n ID_ref_50000.txt > ID_ref_50000.sorted
mv ID_ref_50000.sorted ID_ref_50000.txt

sort -n ID_ref_10000.txt > ID_ref_10000.sorted
mv ID_ref_10000.sorted ID_ref_10000.txt

sort -n ID_ref_2000.txt > ID_ref_2000.sorted
mv ID_ref_2000.sorted ID_ref_2000.txt

sort -n ID_ref_1000.txt > ID_ref_1000.sorted
mv ID_ref_1000.sorted ID_ref_1000.txt

# ??????
rm -r tmp


rm Currentpop_mrk_qtl_${i}.txt 


cd ../
done


####### recode genotype
############ Change to 1000

for i in $(seq -f "%03g" 1 21)
do
cd ${i}

########## changed
tail -120000 genotype_${i}.txt > genotype_nohead_${i}.txt
awk '{print $1}' id_gen.txt > ID_all.txt
paste ID_all.txt genotype_nohead_${i}.txt > Currentpop_mrk_qtl_${i}.txt
rm genotype_nohead_${i}.txt

awk '{prefix = substr($0, 1, 7);rest = substr($0, 8);gsub(/[34]/, "1", rest);print prefix rest}' Currentpop_mrk_qtl_*.txt > genotype1.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_ref_1000.txt genotype1.txt > geno_ref_1000.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_ref_2000.txt genotype1.txt > geno_ref_2000.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_ref_10000.txt genotype1.txt > geno_ref_10000.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_ref_50000.txt genotype1.txt > geno_ref_50000.txt                                                                                                      
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_young.txt genotype1.txt > geno_young.txt  
cat geno_ref_1000.txt geno_young.txt > geno_all_1000.txt
cat geno_ref_2000.txt geno_young.txt > geno_all_2000.txt
cat geno_ref_10000.txt geno_young.txt > geno_all_10000.txt
cat geno_ref_50000.txt geno_young.txt > geno_all_50000.txt

cat geno_ref_1000.txt | cut -c8- > geno_ref1000_noID.txt
sed -E 's/(.)/\1,/g' geno_ref1000_noID.txt > train_1000.csv

cat geno_ref_2000.txt | cut -c8- > geno_ref2000_noID.txt
sed -E 's/(.)/\1,/g' geno_ref2000_noID.txt > train_2000.csv

cat geno_ref_10000.txt | cut -c8- > geno_ref10000_noID.txt
sed -E 's/(.)/\1,/g' geno_ref10000_noID.txt > train_10000.csv

cat geno_ref_50000.txt | cut -c8- > geno_ref50000_noID.txt
sed -E 's/(.)/\1,/g' geno_ref50000_noID.txt > train_50000.csv

cat geno_young.txt | cut -c8- > geno_young_noID.txt
sed -E 's/(.)/\1,/g' geno_young_noID.txt > test.csv 

rm geno_*_noID.txt
rm geno_ref*.txt geno_young.txt genotype1.txt

#### very slow
## xz Currentpop_mrk_qtl_*.txt 

                                                                                   
cd ../
done


####### prepare phenotype files


for folder in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 \
           none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
           low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
           low_medium_aa_5000_0.5 low_medium_aa_100_0.5 low_medium_aa_50_0.5 \
           high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
           none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
           low_high_aa_5000_0.5 low_high_aa_100_0.5 low_high_aa_50_0.5
do

cd ${folder}


for file in *_*.*; do
    if [ -f "$file" ]; then
        folder=$(echo "$file" | grep -oP '\d{3}' | head -1)
        if [ -n "$folder" ]; then
            mkdir -p "$folder"
            mv "$file" "$folder/"
        fi
    fi
done

for i in $(seq -f "%03g" 1 21)
do
cd ${i}


####################### Need to change

for file in $basefolder/$simfolder/${i}/ID_*.txt; do
    ln -s "$file" .
done

for file in $basefolder/$simfolder/${i}/geno_*.txt; do
    ln -s "$file" .
done

########## phenotypes


awk '{print $2, $3}' my_tbvs_Currentpop_*.txt > bv_all.txt 
awk '{print $2, $9}' my_tbvs_Currentpop_*.txt > gv_all.txt 
awk '{print $2, $10}' my_tbvs_Currentpop_*.txt > pheno_all.txt

awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_young.txt bv_all.txt > bv_young_ID.txt
awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_young.txt gv_all.txt > gv_young_ID.txt

awk 'NR==FNR{a[$0]=$0}NR>FNR{if($1==a[$1])print $0}' ID_young.txt pheno_all.txt > pheno_young_ID.txt

awk  '{print $2}' bv_young_ID.txt > bv_young.txt
awk  '{print $2}' gv_young_ID.txt > gv_young.txt
awk  '{print $2}' pheno_young_ID.txt > pheno_young.txt

rm bv_young_ID.txt gv_young_ID.txt pheno_young_ID.txt 


for dir in 1000 2000 10000 50000; do 
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


cd ../
done

cd ../
done

############## End of for loop

########## make superlink for ML models

for scenario in none_none_none_5000_0.5 none_none_none_100_0.5 none_none_none_50_0.5 \
           none_medium_aa_5000_0.5 none_medium_aa_100_0.5 none_medium_aa_50_0.5 \
           low_none_none_5000_0.5 low_none_none_100_0.5 low_none_none_50_0.5 \
           low_medium_aa_5000_0.5 low_medium_aa_100_0.5 low_medium_aa_50_0.5 \
           high_none_none_5000_0.5 high_none_none_100_0.5 high_none_none_50_0.5 \
           none_high_aa_5000_0.5 none_high_aa_100_0.5 none_high_aa_50_0.5 \
           low_high_aa_5000_0.5 low_high_aa_100_0.5 low_high_aa_50_0.5
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





























