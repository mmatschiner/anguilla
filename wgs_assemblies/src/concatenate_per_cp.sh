# m_matschiner Thu Nov 8 19:30:18 CET 2018

# Load modules.
module load ruby/2.1.5

# Concatenate all first codon positions and all second codon positions of all genes in directory 08.
ruby concatenate_per_cp.rb ../res/alignments/orthologs/08 ../res/alignments/orthologs/09