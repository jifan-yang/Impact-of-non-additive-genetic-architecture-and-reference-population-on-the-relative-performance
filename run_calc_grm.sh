#!/bin/sh
#SBATCH --time=0-12:00:00
#SBATCH --mem=11000
#SBATCH --cpus-per-task=1

module load groups

ml SHARED/calc_grm/b202409

calc_grm  
