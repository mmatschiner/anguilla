#!/bin/bash
#SBATCH --job-name=minimap
# m_matschiner Tue Jan 7 14:32:21 CET 2020
#SBATCH --time=10:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=15

# Start with e.g.
# sbatch map_to_mitogenome.slurm reference.fasta reads.fastq.gz mapped.bam

# Abel setup.
source /cluster/bin/jobsetup
module load minimap2/2.17
module load samtools/1.3.1

# Get command line arguments.
reference=`readlink -f ${1}`
gzfastq1=`readlink -f ${2}`
gzfastq2=`readlink -f ${3}`
bam=`readlink -f ${4}`
sam=${bam%.bam}.sam

# Run mapping with minimap2.
if [ ! -f ${sam} ]
then
    minimap2 -t 15 -ax sr ${reference} ${gzfastq1} ${gzfastq2} > ${sam}
fi

# Sort the mapped reads.
cd ${SCRATCH}
samtools view -q 20 -buS ${sam} | samtools sort -m 3G -@ 15 -T tmp -O bam - > ${bam}

# Clean up.
rm -f ${sam}