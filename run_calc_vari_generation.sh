#!/bin/sh
#SBATCH --time=0-7
#SBATCH --mem=9000
#SBATCH --cpus-per-task=1

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder

for scenario in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${scenario}

for i in $(seq -f "%03g" 1 21)
do
cd ${i}


cd 500

head -100 gv_ref.txt > gv_11.txt
awk 'NR>=101 && NR<=200' gv_ref.txt > gv_12.txt
awk 'NR>=201 && NR<=300' gv_ref.txt > gv_13.txt
awk 'NR>=301 && NR<=400' gv_ref.txt > gv_14.txt
tail -100 gv_ref.txt > gv_15.txt

head -100 residual_ref.txt > residual_11.txt
awk 'NR>=101 && NR<=200' residual_ref.txt > residual_12.txt
awk 'NR>=201 && NR<=300' residual_ref.txt > residual_13.txt
awk 'NR>=301 && NR<=400' residual_ref.txt > residual_14.txt
tail -100 residual_ref.txt > residual_15.txt

head -100 pheno.txt > pheno_11.txt
awk 'NR>=101 && NR<=200' pheno.txt > pheno_12.txt
awk 'NR>=201 && NR<=300' pheno.txt > pheno_13.txt
awk 'NR>=301 && NR<=400' pheno.txt > pheno_14.txt
tail -100 pheno.txt > pheno_15.txt

cp $basefolder/scripts/var_com_gens.py .
python var_com_gens.py > variance_com_gens.txt

cd ../

cd 2000

head -400 gv_ref.txt > gv_11.txt
awk 'NR>=401 && NR<=800' gv_ref.txt > gv_12.txt
awk 'NR>=801 && NR<=1200' gv_ref.txt > gv_13.txt
awk 'NR>=1201 && NR<=1600' gv_ref.txt > gv_14.txt
tail -400 gv_ref.txt > gv_15.txt

head -400 residual_ref.txt > residual_11.txt
awk 'NR>=401 && NR<=800' residual_ref.txt > residual_12.txt
awk 'NR>=801 && NR<=1200' residual_ref.txt > residual_13.txt
awk 'NR>=1201 && NR<=1600' residual_ref.txt > residual_14.txt
tail -400 residual_ref.txt > residual_15.txt

head -400 pheno.txt > pheno_11.txt
awk 'NR>=401 && NR<=800' pheno.txt > pheno_12.txt
awk 'NR>=801 && NR<=1200' pheno.txt > pheno_13.txt
awk 'NR>=1201 && NR<=1600' pheno.txt > pheno_14.txt
tail -400 pheno.txt > pheno_15.txt

cp $basefolder/scripts/var_com_gens.py .
python var_com_gens.py > variance_com_gens.txt

cd ../

cd 10000

head -2000 gv_ref.txt > gv_11.txt
awk 'NR>=2001 && NR<=4000' gv_ref.txt > gv_12.txt
awk 'NR>=4001 && NR<=6000' gv_ref.txt > gv_13.txt
awk 'NR>=6001 && NR<=8000' gv_ref.txt > gv_14.txt
tail -2000 gv_ref.txt > gv_15.txt

head -2000 residual_ref.txt > residual_11.txt
awk 'NR>=2001 && NR<=4000' residual_ref.txt > residual_12.txt
awk 'NR>=4001 && NR<=6000' residual_ref.txt > residual_13.txt
awk 'NR>=6001 && NR<=8000' residual_ref.txt > residual_14.txt
tail -2000 residual_ref.txt > residual_15.txt

head -2000 pheno.txt > pheno_11.txt
awk 'NR>=2001 && NR<=4000' pheno.txt > pheno_12.txt
awk 'NR>=4001 && NR<=6000' pheno.txt > pheno_13.txt
awk 'NR>=6001 && NR<=8000' pheno.txt > pheno_14.txt
tail -2000 pheno.txt > pheno_15.txt

cp $basefolder/scripts/var_com_gens.py .
python var_com_gens.py > variance_com_gens.txt

cd ../

cd 50000

head -10000 gv_ref.txt > gv_11.txt
awk 'NR>=10001 && NR<=20000' gv_ref.txt > gv_12.txt
awk 'NR>=20001 && NR<=30000' gv_ref.txt > gv_13.txt
awk 'NR>=30001 && NR<=40000' gv_ref.txt > gv_14.txt
tail -10000 gv_ref.txt > gv_15.txt

head -10000 residual_ref.txt > residual_11.txt
awk 'NR>=10001 && NR<=20000' residual_ref.txt > residual_12.txt
awk 'NR>=20001 && NR<=30000' residual_ref.txt > residual_13.txt
awk 'NR>=30001 && NR<=40000' residual_ref.txt > residual_14.txt
tail -10000 residual_ref.txt > residual_15.txt

head -10000 pheno.txt > pheno_11.txt
awk 'NR>=10001 && NR<=20000' pheno.txt > pheno_12.txt
awk 'NR>=20001 && NR<=30000' pheno.txt > pheno_13.txt
awk 'NR>=30001 && NR<=40000' pheno.txt > pheno_14.txt
tail -10000 pheno.txt > pheno_15.txt

cp $basefolder/scripts/var_com_gens.py .
python var_com_gens.py > variance_com_gens.txt

cd ../


cd ../
done


cd ../
done


for scenario in none_none_none_5000_0.5 none_none_none_5000_0.1 none_none_none_100_0.5 none_none_none_100_0.1 none_none_none_50_0.5 none_none_none_50_0.1
do
cd ${scenario}


for i in $(seq -f "%03g" 1 21)
do


for ref in 500 2000 10000 50000
do

for gen in $(seq 11 16)
do

val1=$(grep "Genetic Variance of Gen ${gen}" ./${i}/${ref}/variance_com_gens.txt | awk '{print $6}') 
val2=$(grep "Residual Variance of Gen ${gen}" ./${i}/${ref}/variance_com_gens.txt | awk '{print $6}') 
val3=$(grep "Phenotypic Variance of Gen ${gen}" ./${i}/${ref}/variance_com_gens.txt | awk '{print $6}') 
val4=$(grep "h2_${gen}" ./${i}/${ref}/variance_com_gens.txt | awk '{print $2}') 


val5=$(grep "Genetic Variance of Ref" ./${i}/${ref}/variance_component.txt| awk '{print $5}') 
val6=$(grep "Residual Variance of Ref" ./${i}/${ref}/variance_component.txt| awk '{print $5}') 
val7=$(grep "Phenotypic Variance of Ref" ./${i}/${ref}/variance_component.txt| awk '{print $5}') 
val8=$(grep "h2_ref" ./${i}/${ref}/variance_component.txt| awk '{print $2}') 


echo -e "${i}\t${gen}\t${val1}\t${val2}\t${val3}\t${val4}\t${val5}\t${val6}\t${val7}\t${val8}\tYes" >> var_com_gens_${ref}.txt

done
done
done

cd ../
done























