#!/bin/bash
#SBATCH --comment=4100000640
#SBATCH --time=0-01:00:00
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=sample_effects


#SBATCH --array=1-21%7
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8000
#-----------------------------Environment, Operations and Job steps----

cd /lustre/scratch/WUR/ABGC/yang110/simulations
module load julia/1.8.5

# set parameters for sampling effects
dom="none"   # how much dominance (low, medium, high)
epi="none"   # how much epistasis #large
nqtl=5000    # number of QTL to sample
qtlfold="effects_additive_5000"   # folder to store QTL effects

# create folder
mkdir -p $qtlfold

# find replicate number from SLURM
rep=$SLURM_ARRAY_TASK_ID 
repl=$(printf "%03d" $rep) 

# sample additive, dominance, and epistatic effects (none means that dom and epistatic are 0)
julia scripts/sample_a.jl $repl $nqtl $qtlfold
julia scripts/sample_d.jl $repl $dom $qtlfold
julia scripts/sample_e.jl $repl $epi 5 $qtlfold    # 5 is the number of interactions between loci. Not important now

# sample epistatic combinations. Below means interactions of 1 qtl with 5 others.
julia scripts/sample_epicombinations.jl $repl $nqtl 5 $qtlfold


# make subsamples for other scenarios with differen number of QTL. Make sure to include all your alternative n_qtl scenario here (not sure what numbers you used exactly)
# create folders
mkdir -p effects_additive_50
mkdir -p effects_additive_100

# resample qtl loci and effects
julia scripts/resample_qtl.jl $repl $qtlfold 100 $epi 5 effects_additive_100
qtlfold100="effects_additive_100" 
julia scripts/resample_qtl.jl $repl $qtlfold100 50 $epi 5 effects_additive_50

cd effects_additive_50

awk 'NR==FNR { b[NR] = $0; next } { print b[$1] }' ../effects_additive_100/selected_${repl}.dat selected_${repl}.dat > A_${repl}.tmp

rm selected_${repl}.dat
mv A_${repl}.tmp selected_${repl}.dat
rm A_${repl}.tmp





