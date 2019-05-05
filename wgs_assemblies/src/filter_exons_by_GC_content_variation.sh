# m_matschiner Sun Jul 22 15:15:26 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Make the output directory.
mkdir -p ../res/alignments/orthologs/06
rm -f ../res/alignments/orthologs/06/*

# Remove exons that are outliers in gc-content variation.
ruby filter_exons_by_GC_content_variation.rb ../res/alignments/orthologs/05 ../res/alignments/orthologs/06 0.03