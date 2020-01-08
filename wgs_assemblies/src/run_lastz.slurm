#!/bin/bash

# m_matschiner Sat Jan 6 16:28:54 CET 2018

# Job name:
#SBATCH --job-name=wgaltz
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=61G

## Set up the job environment.
source /cluster/bin/jobsetup
module load lastz/1.04

## Feedback.
echo
echo "run_lastz.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
target=${1}
query_prefix=${2}
params=${3}
out_prefix=${4}

# Feedback.
echo "Target file: ${target}"
echo "Query prefix: ${query_prefix}"
echo "Parameters: ${params}"
echo "Output prefix: ${out_prefix}" 
echo

# Run lastz.
for query in ${query_prefix}??.fa
do
    n=`echo ${query} | rev | cut -c 4,5 | rev`
    out_file_name="${out_prefix}${n}.lav"
    lastz ${target} ${query} ${params} > ${out_file_name}
done

