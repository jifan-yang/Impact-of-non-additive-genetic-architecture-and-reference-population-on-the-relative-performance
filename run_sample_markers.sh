#!/bin/bash
#SBATCH --time=02-06:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=sample_markers

#SBATCH --array=1-21%11
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=150000
#-----------------------------Environment, Operations and Job steps----

basefolder="/lustre/scratch/WUR/ABGC/yang110/simulations"

################## make sure the qtl qtlfolder is correct 
qtlfolder="effects_additive_5000"   ############ Need to change

simfolder="data/r_simulation"
module load julia/1.8.5
module load R/4.2.0

# set parameters for scenario
domval="none"  # no dominance
epival="none"  # no epistasis
epimod="none"  # no epistasis
nqtl=5000    # 10 QTL ############ Need to change
h2=0.5     # heritability ############ Need to change   
nreqmarkers=20000    # 20,000 markers

echo $domval $epival $epimod $nqtl $h2

# get replicate number from slurm
rep=$SLURM_ARRAY_TASK_ID 
repl=$(printf "%03d" $rep) 

echo "Replicate ${repl}"
cd $basefolder
cd $simfolder
	
# go to scenario folder #
# nm="${domval}_${epival}_${epimod}_${nqtl}_${h2}"
# cd $nm


# make folder for replicate 
mkdir -p $repl

# format data
# data1="Currentpop_data_${repl}.txt"
# Rscript $basefolder/scripts/format_data.R $data1

# copy qtlloci file 
cp qtlloci_${repl}_${nqtl}.dat ${repl}


# allele frequencies #
julia $basefolder/scripts/allele_frequencies.jl $repl Currentpop 16 $basefolder
julia $basefolder/scripts/allele_frequencies.jl $repl Currentpop 15 $basefolder
julia $basefolder/scripts/allele_frequencies.jl $repl Currentpop 14 $basefolder
julia $basefolder/scripts/allele_frequencies.jl $repl Currentpop 13 $basefolder
julia $basefolder/scripts/allele_frequencies.jl $repl Currentpop 12 $basefolder
julia $basefolder/scripts/allele_frequencies.jl $repl Currentpop 11 $basefolder
############ Need to change generations

# make U-shape histogram
cd $repl
ln -s $basefolder/scripts/allelefreq.py
ln -s $basefolder/scripts/allelefreq_nonfix.py
python allelefreq.py
python allelefreq_nonfix.py
cd ../


# sample marker loci 
julia $basefolder/scripts/sample_loci_markers.jl $repl $nreqmarkers Currentpop 16 $basefolder
############ Need to change generations


# Start calculate LD for selected markers
sort -n markerloci_Currentpop_$repl.dat > mrkloci_$repl.txt

sed '1d' lm_mrk_qtl_$repl.txt > lm_$repl.txt

awk 'NR==FNR {lines[$1]; next} FNR in lines' mrkloci_$repl.txt lm_$repl.txt > lm_new_$repl.txt

mkdir LDselected_$repl
sed -i '1i ID          Chr    Position' lm_new_$repl.txt
mv lm_new_$repl.txt ./LDselected_$repl/


cd LDselected_$repl
mv lm_new_$repl.txt lm_mrk_qtl_$repl.txt
cd ../

## make genotype for LD

cat Currentpop_mrk_qtl_$repl.txt | cut -c9- > geno_$repl.txt
cat Currentpop_mrk_qtl_$repl.txt | cut -c1-6 > ID_$repl.txt

awk 'NR==FNR {positions[NR]=$1; next} {line=""; for (i=1; i<=length(positions); i++) line=line substr($0, positions[i], 1); print line}' mrkloci_$repl.txt geno_$repl.txt > genotype_$repl.txt

awk 'NR==FNR {a[NR]=$1; next} {printf "%-7s%s\n", a[FNR], $1}' ID_$repl.txt genotype_$repl.txt > geno1_$repl.txt
mv geno1_$repl.txt ./LDselected_$repl/

cd LDselected_$repl
mv geno1_$repl.txt Currentpop_mrk_qtl_$repl.txt
ln -s $basefolder/$simfolder/Currentpop_data_${repl}_reformat.dat

# LD of selected markers#
julia $basefolder/scripts/ld.jl $repl Currentpop 16 20 $basefolder
## generation/maxdistance in chromosome (cM)
############ Need to change generations

cd $repl
numb=$(awk '$1 > 2 {print NR; exit}' ld_*.dat)
head -$numb ld_*.dat > ld_2.txt
numb=$(awk '$1 > 0.1 {print NR; exit}' ld_*.dat)
head -$numb ld_*.dat > ld_less.txt

ln -s $basefolder/scripts/LD_plot_less.py
python LD_plot_less.py
ln -s $basefolder/scripts/LD_plot_2.py
python LD_plot_2.py



# LD 
#julia $basefolder/scripts/ld.jl $repl Currentpop 16 20 $basefolder
## generation/maxdistance in chromosome (cM)


# copy qtlloci file 
#cp "${basefolder}/${qtlfolder}/qtlloci_${repl}.dat" "qtlloci_${repl}.dat"

