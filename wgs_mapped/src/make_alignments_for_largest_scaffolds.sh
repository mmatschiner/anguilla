# m_matschiner Sat Apr 13 18:56:21 CEST 2019

# Make the result directory.
mkdir -p ../res/sliding_window_phylogenies/alignments/full

# Make the log directory.
mkdir -p ../log/sliding_window_phylogenies

# Uncompress fastq files if they are present.
if [ -f ../data/fastq/angmar.mapped.fq.gz ]
then
	gunzip ../data/fastq/angmar.mapped.fq.gz
fi
if [ -f ../data/fastq/angmeg.mapped.fq.gz ]
then
	gunzip ../data/fastq/angmeg.mapped.fq.gz
fi
if [ -f ../data/fastq/angobs.mapped.fq.gz ]
then
	gunzip ../data/fastq/angobs.mapped.fq.gz
fi

# Ensure that the mapped fastq files are in place.
if [ ! -f ../data/fastq/angmar.mapped.fq ]
then
	echo "Please download the file angmar.mapped.fq.gz from the Dryad repository and place it in '../data/fastq', then restart this script."
	exit 0
fi
if [ ! -f ../data/fastq/angmeg.mapped.fq ]
then
	echo "Please download the file angmeg.mapped.fq.gz from the Dryad repository and place it in '../data/fastq', then restart this script."
	exit 0
fi
if [ ! -f ../data/fastq/angobs.mapped.fq ]
then
	echo "Please download the file angobs.mapped.fq.gz from the Dryad repository and place it in '../data/fastq', then restart this script."
	exit 0
fi

# Ensure that the anguilla reference is in place.
if [ ! -f ../data/reference/angang.fasta ]
then
	echo "Please run script simplify_ref.sh before running this script."
	exit 0
fi

# Set the three fastq files.
fq1=../data/fastq/angobs.mapped.fq
fq2=../data/fastq/angmar.mapped.fq
fq3=../data/fastq/angmeg.mapped.fq
outgroup=../data/reference/angang.fasta
output_dir=../res/sliding_window_phylogenies/alignments/full

# Calculate abba-baba for the species quartet.
out=../log/sliding_window_phylogenies/make_alignments.txt
rm -f ${out}
sbatch -o ${out} make_alignments_for_largest_scaffolds.slurm ${fq1} ${fq2} ${fq3} ${outgroup} ${output_dir}
