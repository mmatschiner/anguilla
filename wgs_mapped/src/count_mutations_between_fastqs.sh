# m_matschiner Sat Dec 29 12:47:12 CET 2018

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

# Load the ruby module.
module load ruby/2.1.5

# Make the output directory.
mkdir -p ../res/out

# Count the numbers of mutations in pairwise comparisons.
ruby count_mutations_between_fastqs.rb ../data/fastq/angmar.mapped.fq ../data/fastq/angmeg.mapped.fq > ../res/out/mar_meg.out
ruby count_mutations_between_fastqs.rb ../data/fastq/angmar.mapped.fq ../data/fastq/angobs.mapped.fq > ../res/out/mar_obs.out
ruby count_mutations_between_fastqs.rb ../data/fastq/angmeg.mapped.fq ../data/fastq/angobs.mapped.fq > ../res/out/meg_obs.out