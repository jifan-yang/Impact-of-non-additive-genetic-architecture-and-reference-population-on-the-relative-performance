#!/bin/bash
#SBATCH --time=00-05:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=simulate

#SBATCH --ntasks=1
#SBATCH --array=1-21%11
#SBATCH --cpus-per-task=3
#SBATCH --mem-per-cpu=20000
#-----------------------------Environment, Operations and Job steps----

# get replicate number from slurm
rep=$SLURM_ARRAY_TASK_ID 
repl=$(printf "%03d" $rep) 

echo "Replicate ${repl}"

# load software
ml load julia/1.8.5
#ml load R/4.2.0

# set folders
basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations" # set the starting folder here
qtlfolder="effects_additive_5000"   # folder where you stored the effects
simfolder="data/r_simulation" # folder where the simulated data is stored

# go to basefolder
echo $basefolder
cd $basefolder
cd $simfolder

# set parameters for scenario
domval="none"  # no dominance
epival="none"  # no epistasis
epimod="none"  # no epistasis
nqtl=5000    # Nr. QTL
h2=0.1  # heritability

# format data
# data1="Currentpop_data_${repl}.txt"
# Rscript $basefolder/scripts/format_data.R $data1

##ln -s ${repl}/Currentpop_data_${repl}_reformat.dat
##ln -s ${repl}/qtlloci_${repl}_5000.dat

##ln -s /lustre/scratch/WUR/ABGC/yang110/simulations2/data/r_simulation/${repl}/ID_${repl}.txt
##ln -s /lustre/scratch/WUR/ABGC/yang110/simulations2/data/r_simulation/${repl}/geno_${repl}.txt
##paste ID_${repl}.txt geno_${repl}.txt > Currentpop_mrk_qtl_${repl}.txt


# create scenario folder #
nm="${domval}_${epival}_${epimod}_${nqtl}_${h2}"



mkdir -p $nm
cd $nm
cp ../qtlloci_${repl}_5000.dat .


# compute ebv and phenotypes 
julia $basefolder/scripts/ebv_aftersim.jl Currentpop $simfolder $epimod 11 $repl $h2 $qtlfolder $basefolder
julia $basefolder/scripts/ebv_aftersim.jl Currentpop $simfolder $epimod 12 $repl $h2 $qtlfolder $basefolder
julia $basefolder/scripts/ebv_aftersim.jl Currentpop $simfolder $epimod 13 $repl $h2 $qtlfolder $basefolder
julia $basefolder/scripts/ebv_aftersim.jl Currentpop $simfolder $epimod 14 $repl $h2 $qtlfolder $basefolder
julia $basefolder/scripts/ebv_aftersim.jl Currentpop $simfolder $epimod 15 $repl $h2 $qtlfolder $basefolder
julia $basefolder/scripts/ebv_aftersim.jl Currentpop $simfolder $epimod 16 $repl $h2 $qtlfolder $basefolder

