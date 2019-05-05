#!/bin/bash

# Job name:
#SBATCH --job-name=snapp
#
# Wall clock limit:
#SBATCH --time=100:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=5
#SBATCH --nodes=1
#SBATCH --mem-per-cpu=5G

## Set up job environment:
source /cluster/bin/jobsetup
module load beast2/2.5.0

# Get the command-line arguments.
xml=${1}

# Run snapp.
if [ -f ${xml%.xml}.log ]
then
    beast -threads 4 -resume -seed ${RANDOM} ${xml}
else
    beast -threads 4 -seed ${RANDOM} ${xml}
fi