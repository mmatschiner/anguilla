#!/bin/bash

# Job name:
#SBATCH --job-name=mkaln
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
output_dir=${5}

# Make alignments for the scaffolds longer than 5 mbp.
ruby make_alignments_for_largest_scaffolds.rb ${fq1} ${fq2} ${fq3} ${outgroup} ${output_dir}