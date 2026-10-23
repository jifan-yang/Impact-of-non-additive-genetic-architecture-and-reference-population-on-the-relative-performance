#!/bin/bash
#SBATCH --time=0-19:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=data_processing
#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=11000

#-----------------------------Environment, Operations and Job steps----
basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation"

cd ${basefolder}/${simfolder} 

for i in $(seq -f "%03g" 1 21)
do
cd ${i}

########## changed
tail -120000 genotype_${i}.txt > genotype_nohead_${i}.txt
awk '{print $1}' id_gen.txt > ID_all.txt
paste -d ' ' ID_all.txt genotype_nohead_${i}.txt > Currentpop_mrk_qtl_${i}.txt

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



rm geno_young.txt genotype1.txt


                                                                                   
cd ../
done
