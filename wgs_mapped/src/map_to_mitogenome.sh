# m_matschiner Tue Jan 7 14:06:05 CET 2020

# Make the log directory.
mkdir -p ../log/misc

# Make the results directory.
mkdir -p ../res/minimap

# Make the data directory.
mkdir -p ../data/subjects

# Set the mitogenomes.
angmar_mt=../data/queries/angmar_NC_006540.fasta
angmeg_mt=../data/queries/angmeg_NC_006541.fasta

# Ensure that the fasta files for marmorata, megastoma, and obscura are in place.
if [ ! -f ../data/subjects/angmar.r1.fastq.gz ]
then
    echo "Please download the A. marmorata reads from ENA (accession PRJEB32187), name the files 'angmar.r1.fastq.gz' and 'angmar.r2.fastq.gz', and place them in '../data/subjects', then restart this script."
    exit 0
fi
if [ ! -f ../data/subjects/angmeg.r1.fastq.gz ]
then
    echo "Please download the A. megastoma reads from ENA (accession PRJEB32187), name the files 'angmeg.r1.fastq.gz' and 'angmeg.r2.fastq.gz', and place them in '../data/subjects', then restart this script."
    exit 0
fi

# Map the marmorata reads.
out=../log/misc/minimap.mar.out
rm -f ${out}
sbatch -o ${out} --account ${acct} map_to_mitogenome.slurm ${angmar_mt} angmar.r1.fastq.gz angmar.r2.fastq.gz ../res/minimap/mar.bam

# Map the marmorata reads.
out=../log/misc/minimap.meg.out
rm -f ${out}
sbatch -o ${out} --account ${acct} map_to_mitogenome.slurm ${angmeg_mt} angmeg.r1.fastq.gz angmeg.r2.fastq.gz ../res/minimap/meg.bam
