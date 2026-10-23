#!/bin/sh
#SBATCH --time=01-19:00:00    # days-hh:mm:ss
#SBATCH --mem=15G 
#SBATCH --cpus-per-task=1

 
python myscript.py > output.txt

