# m_matschiner Wed Dec 25 20:35:39 CET 2019

# Load modules.
module load ruby/2.1.5

# Use a ruby script to determine coding changes in each mitochondrial alignment.
for fasta in ../res/alignments/*.fasta
do
    table=${fasta%.fasta}.txt
    ruby identify_coding_changes.rb ${fasta} ${table}
done