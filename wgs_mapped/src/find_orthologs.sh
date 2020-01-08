# m_matschiner Wed Dec 25 14:23:10 CET 2019

# Make the output directory.
mkdir -p ../res/alignments

# Make the log directory.
mkdir -p ../log/misc

# Set the account.
acct=nn9244k

# Generate a list of all subject sequence fasta files
# (use readlink and -d so that) the absolute paths are specified.
ls -d `readlink -f ../res/mitobim/`/*.fasta > ../res/mitobim/subjects.txt

# Search for orthologs to the query in all subject sequences.
query=../data/queries/angang_mt_NC_006531_protein_coding_nucleotide.txt
out=../log/misc/find_orthologs.out
rm -f ${out}
sbatch -o ${out} --account ${acct} find_orthologs.slurm ${query} ../res/mitobim/subjects.txt ../res/alignments
