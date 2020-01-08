#!/bin/bash

# m_matschiner Tue Dec 10 10:00:48 CET 2019

# Job name:
#SBATCH --job-name=idnrrg
#
# Wall clock limit:
#SBATCH --time=10:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=1G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5

## Feedback.
echo
echo "identify_rearrangements_from_maf.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
maf=`readlink -f ${1}`
min_score=${2}
min_length=${3}
table=`readlink -f ${4}`

# Copy the ruby script to the temporary directory.
cp identify_rearrangements_from_maf.rb ${SCRATCH}

# Move to the temporary directory.
cd ${SCRATCH}

# Make a reduced version of the maf file.
cat ${maf} | grep -v "#" | tr -s " " | cut -d " " -f 1-6 > tmp.red.maf

# Use a ruby script to identify rearrangements.
ruby identify_rearrangements_from_maf.rb tmp.red.maf ${min_score} ${min_length} ${table}