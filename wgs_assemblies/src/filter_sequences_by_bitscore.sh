# m_matschiner Fri Sep 14 08:38:23 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/alignments/orthologs/02

# Filter sequences by their blast bitscores.
ruby filter_sequences_by_bitscore.rb ../res/alignments/orthologs/01/ ../res/alignments/orthologs/02/ 0.9