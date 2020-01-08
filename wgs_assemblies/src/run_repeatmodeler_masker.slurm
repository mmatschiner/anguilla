#!/bin/sh

#SBATCH --job-name=repeatmodeler
#SBATCH --account=nn9244k
#SBATCH --time=168:0:0
#SBATCH --mem-per-cpu=3900M 
#SBATCH --cpus-per-task=16

## Set up the job environment.
source /cluster/bin/jobsetup
module load repeatmodeler/1.0.8
module load gcc/7.2.0

## Feedback.
echo
echo "run_repeatmodeler_masker.slurm was called with arguments ${@}."
echo

# Get the repeat library directory.
repeat_lib_dir=`readlink -f ${1}`

# Get the assembly file.
assembly=`readlink -f ${3}`

# Make the repeat library directory and move into it.
mkdir -p ${repeat_lib_dir}
cd ${repeat_lib_dir}

# Get the assembly id.
assembly_id=${2}

# Make a subdirectory named as the assembly id and move into it.
mkdir -p ${assembly_id}
cd ${assembly_id}

# Build a repeat database.
BuildDatabase -name ${assembly_id} -engine ncbi ${assembly}

# Identify repeats.
RepeatModeler -engine ncbi -pa 16 -database ${assembly_id} 1> repeatmodeler.out 2> repeatmodeler.err

# Mask repeats.
RepeatMasker -lib RM*/consensi.fa.classified ${assembly} -xsmall -pa 16 1> repeatmasker.out 2> repeatmasker.err
