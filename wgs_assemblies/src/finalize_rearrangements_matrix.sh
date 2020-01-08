# m_matschiner Wed Dec 11 23:27:36 CET 2019

# Load modules.
module load ruby/2.1.5
module load blast+/2.2.29

# Set the matrix.
matrix=../res/tables/rearrangements.matrix.txt

# Set the annotation file.
gff=../data/assemblies/augustus.gff

# Set the sorted matrix.
finalized_matrix=${matrix%.txt}.finalized.txt

# Set the protein sequences file name.
mkdir -p ../data/protein_sequences
prot_seqs=../data/protein_sequences/danrer.fasta

# Download the zebrafish proteome.
if [ ! -f ${prot_seqs} ]
then
    wget ftp://ftp.ensembl.org/pub/release-98/fasta/danio_rerio/pep/Danio_rerio.GRCz11.pep.all.fa.gz
    gunzip Danio_rerio.GRCz11.pep.all.fa.gz
    mv -f Danio_rerio.GRCz11.pep.all.fa ${prot_seqs}
fi

# Make blast libraries.
if [ ! -f ${prot_seqs}.phr ]
then
    makeblastdb -in ${prot_seqs} -dbtype prot
fi

# Use a ruby script to sort the matrix.
ruby finalize_rearrangements_matrix.rb ${matrix} ${gff} ${prot_seqs} ${finalized_matrix}