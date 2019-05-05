# m_matschiner Tue Sep 18 09:40:28 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Make the output directory.
mkdir -p ../res/alignments/orthologs/07
rm -rf ../res/alignments/orthologs/07/*

# Remove genes with too few exon alignments within close proximity.
ruby filter_genes_by_exon_number.rb ../res/alignments/orthologs/06 ../res/alignments/orthologs/07 ../data/tables/nuclear_queries_exons.txt 3

# Remove the subdirectory structure in directory 07.
mkdir tmp
mv ../res/alignments/orthologs/07/*/*.fasta tmp
rm -r ../res/alignments/orthologs/07/*
mv tmp/* ../res/alignments/orthologs/07
rm -r tmp