#!/bin/bash

# m_matschiner Tue Dec 4 14:11:15 CET 2018

#SBATCH --job-name=iqtree
#SBATCH --time=100:00:00
#SBATCH --mem-per-cpu=1G
#SBATCH --cpus-per-task=5

# Set up.
source /cluster/bin/jobsetup
module load iqtree/1.7-beta7

# Get the command-line arguments.
nex=`readlink -f ${1}`
nex_base=`basename ${nex}`
tree_dir=`readlink -f ${2}`

# Copy the alignment file to the temporary directory.
cp ${nex} ${SCRATCH}

# Change to the temporary directory.
cd ${SCRATCH}

# Run iqtree.
iqtree -nt 5 -s ${nex_base} -p ${nex_base} --prefix concat -bb 1000
iqtree -nt 5 -s ${nex_base} -S ${nex_base} --prefix loci
iqtree -t concat.treefile --gcf loci.treefile -s ${nex_base} --scf 100 --prefix concord

# Return the result files.
cp * ${tree_dir}
