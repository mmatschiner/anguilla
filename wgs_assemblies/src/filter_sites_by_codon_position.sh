# m_matschiner Sun Mar 19 13:48:14 CET 2017

# Load the ruby module.
module load ruby/2.1.5

# Make the output directory.
mkdir -p ../res/alignments/orthologs/05

# Remove third codon positions.
ruby filter_sites_by_codon_position.rb ../res/alignments/orthologs/04/ ../res/alignments/orthologs/05