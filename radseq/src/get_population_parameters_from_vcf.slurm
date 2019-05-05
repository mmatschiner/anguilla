#!/bin/bash

# m_matschiner Mon Feb 25 23:32:41 CET 2019

# Job name:
#SBATCH --job-name=poppar
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=30G

## Set up the job environment.
source /cluster/bin/jobsetup
module load ruby/2.1.5

## Feedback.
echo
echo "get_population_parameters.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
vcf=${1}
callable_genome_size=${2}
table_file=${3}

# Get population parameters from vcf.
ruby get_population_parameters_from_vcf.rb ${vcf} ${callable_genome_size} ${table_file}