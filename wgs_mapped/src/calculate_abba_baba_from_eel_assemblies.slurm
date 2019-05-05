#!/bin/bash

# Job name:
#SBATCH --job-name=abba
#
# Wall clock limit:
#SBATCH --time=100:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=30G

## Set up job environment:
source /cluster/bin/jobsetup
module load ruby/2.1.5

# Get the command-line arguments.
fq1=${1}
fq2=${2}
fq3=${3}
outgroup=${4}
table=${5}

# Calculate abba-baba statstics from the three eel assemblies plus the reference.
ruby calculate_abba_baba_from_eel_assemblies.rb ${fq1} ${fq2} ${fq3} ${outgroup} ${table}