#!/bin/bash

# m_matschiner Wed Oct 24 17:38:49 CEST 2018
#SBATCH --job-name=f4
#
# Wall clock limit:
#SBATCH --time=100:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=5G

## Set up job environment:
source /cluster/bin/jobsetup
module load python3/3.5.0
module load fastsimcoal/2.6.0.3

# Get the command-line arguments.
file=`readlink -f ${1}`
res=`readlink -f ${2}`
log=`readlink -f ${3}`

# Copy the f4 script to the temporary directory.
cp f4.py ${SCRATCH}

# Change to the temporary directory.
cd ${SCRATCH}

# Run f4.
python3 f4.py -k 20 -s 1000 -l ${log} -x fsc26 ${file} ${res}