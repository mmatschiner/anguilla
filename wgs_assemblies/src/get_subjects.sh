# m_matschiner Thu Nov 8 12:26:57 CET 2018

# Make a subject directory.
mkdir -p ../data/subjects

# Ensure that the fasta files for marmorata, megastoma, and obscura are in place.
if [ ! -f ../data/subjects/angmar.fasta ]
then
	echo "Please download the A. marmorata assembly from ENA (accession PRJEB32187), name it 'angmar.fasta', and place it in '../data/subjects', then restart this script."
	exit 0
fi
if [ ! -f ../data/subjects/angmeg.fasta ]
then
	echo "Please download the A. megastoma assembly from ENA (accession PRJEB32187), name it 'angmeg.fasta', and place it in '../data/subjects', then restart this script."
	exit 0
fi
if [ ! -f ../data/subjects/angobs.fasta ]
then
	echo "Please download the A. obscura assembly from ENA (accession PRJEB32187), name it 'angobs.fasta', and place it in '../data/subjects', then restart this script."
	exit 0
fi

# Get ncbi assemblies.
if [ ! -f ../data/subjects/angang.fasta ]
then
    wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/695/075/GCA_000695075.1_Anguilla_anguilla_v1_09_nov_10/GCA_000695075.1_Anguilla_anguilla_v1_09_nov_10_genomic.fna.gz
    gunzip GCA_000695075.1_Anguilla_anguilla_v1_09_nov_10_genomic.fna.gz
    mv GCA_000695075.1_Anguilla_anguilla_v1_09_nov_10_genomic.fna ../data/subjects/angang.fasta
fi
if [ ! -f ../data/subjects/angjap.fasta ]
then
    wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/470/695/GCA_000470695.1_japanese_eel_genome_v1_25_oct_2011_japonica_c401b400k25m200_sspacepremiumk3a02n24_extra.final.scaffolds/GCA_000470695.1_japanese_eel_genome_v1_25_oct_2011_japonica_c401b400k25m200_sspacepremiumk3a02n24_extra.final.scaffolds_genomic.fna.gz
    gunzip GCA_000470695.1_japanese_eel_genome_v1_25_oct_2011_japonica_c401b400k25m200_sspacepremiumk3a02n24_extra.final.scaffolds_genomic.fna.gz
    mv GCA_000470695.1_japanese_eel_genome_v1_25_oct_2011_japonica_c401b400k25m200_sspacepremiumk3a02n24_extra.final.scaffolds_genomic.fna ../data/subjects/angjap.fasta
fi
