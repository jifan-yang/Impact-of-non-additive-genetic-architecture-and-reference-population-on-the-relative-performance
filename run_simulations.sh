#!/bin/bash
#SBATCH --comment=4100000640
#SBATCH --time=00-05:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=simulate

#SBATCH --mail-type=END
#SBATCH --mail-user=pascal.duenk@wur.nl

#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=8000
#-----------------------------Environment, Operations and Job steps----

ml load julia

basefolder="/lustre/nobackup/WUR/ABGC/duenk002/jifan_test" # set the starting folder here
qtlfolder="effects_additive"   # folder where you stored the effects

# go to basefolder
echo $basefolder
cd $basefolder

# set parameters for scenario
domval="none"  # no dominance
epival="none"  # no epistasis
epimod="none"  # no epistasis

echo $domval $epival $epimod

# create scenario folder #
nm="${domval}_${epival}_${epimod}"

mkdir -p $nm
cd $nm

# copy parameter file and seed file to the scenario folder
prm="${nm}.prm"	
cp "${basefolder}/scripts/simulation.prm" $prm
cp "${basefolder}/scripts/masterseed" seed

# copy script that computes bv and phenotypes to the scenario folder #
cp $basefolder/scripts/calc_ebv_pheno.sh calc_ebv_pheno.sh
chmod 777 $basefolder/scripts/calc_ebv_pheno.sh calc_ebv_pheno.sh

# run simulation for this scenario #
/home/WUR/duenk002/QMSim/QMSim $prm -o 

cd ..
