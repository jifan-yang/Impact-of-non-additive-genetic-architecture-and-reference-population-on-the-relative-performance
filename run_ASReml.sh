#!/bin/bash
#SBATCH --time=1-19:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=data_processing

#SBATCH --array=1-1%1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=15000
#-----------------------------Environment, Operations and Job steps----


basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"
simfolder="data/r_simulation" 

cd $basefolder/$simfolder

for repl in 002 005 007 008 011 014 020
do
cd ${repl}/500
mkdir -p ASReml
cd ASReml
cp $basefolder/scripts/calc.inp .
mv calc.inp calc_grm.inp
ln -s ../genotype.txt
calc_grm

cd ../../../
done


##########
cd none_none_none_50_0.1

for repl in 002 005 007 011 020
do
cd ${repl}/500
mkdir -p ASReml
cd ASReml
ln -s $basefolder/$simfolder/${repl}/500/ASReml/G_asreml.giv
cp $basefolder/scripts/GBLUP.as .
cp ../phenotype.txt .
awk '{print $1, $2, $3}' phenotype.txt > pheno.txt
rm phenotype.txt
mv pheno.txt phenotype.txt

cp ../bv_young.txt .
cp ../gv_young.txt .
cp ../gv_ref.txt .
cp ../pheno.txt .
cp ../pheno_young.txt .

/cm/shared/apps/WUR/ABGC/asreml4.2.1.45/bin/asreml.sh -NRS20000 GBLUP.as
cp $basefolder/scripts/run_ASReml_stats.sh .
sbatch run_ASReml_stats.sh

cd ../

cd ../../
done

cd ../
###################
cd none_none_none_100_0.1

for repl in 008 020
do
cd ${repl}/500
mkdir -p ASReml
cd ASReml
ln -s $basefolder/$simfolder/${repl}/500/ASReml/G_asreml.giv
cp $basefolder/scripts/GBLUP.as .
cp ../phenotype.txt .
awk '{print $1, $2, $3}' phenotype.txt > pheno.txt
rm phenotype.txt
mv pheno.txt phenotype.txt

cp ../bv_young.txt .
cp ../gv_young.txt .
cp ../gv_ref.txt .
cp ../pheno.txt .
cp ../pheno_young.txt .

/cm/shared/apps/WUR/ABGC/asreml4.2.1.45/bin/asreml.sh -NRS20000 GBLUP.as
cp $basefolder/scripts/run_ASReml_stats.sh .
sbatch run_ASReml_stats.sh

cd ../

cd ../../
done

cd ../

####################

cd none_none_none_5000_0.1

for repl in 002 008 014
do
cd ${repl}/500
mkdir -p ASReml
cd ASReml
ln -s $basefolder/$simfolder/${repl}/500/ASReml/G_asreml.giv
cp $basefolder/scripts/GBLUP.as .
cp ../phenotype.txt .
awk '{print $1, $2, $3}' phenotype.txt > pheno.txt
rm phenotype.txt
mv pheno.txt phenotype.txt

cp ../bv_young.txt .
cp ../gv_young.txt .
cp ../gv_ref.txt .
cp ../pheno.txt .
cp ../pheno_young.txt .

/cm/shared/apps/WUR/ABGC/asreml4.2.1.45/bin/asreml.sh -NRS20000 GBLUP.as
cp $basefolder/scripts/run_ASReml_stats.sh .
sbatch run_ASReml_stats.sh

cd ../

cd ../../
done

cd ../

























