# m_matschiner Tue Jan 8 16:53:25 CET 2019

# Load modules.
module load python3/3.5.0

# Uncompress the compressed fasta directory if it is present.
if [ -f ../data/fasta/anguilla_aln1.tgz ]
then
	cd ../data/fasta
	tar -xzf ../data/fasta/anguilla_aln1.tgz
	cd -
fi

# Ensure that the uncompressed fasta directory is in place.
if [ ! -d ../data/fasta/anguilla_aln1 ]
then
	echo "Please download the file anguilla_aln1.tgz from the Dryad repository and place it in '../data/fasta', then restart this script."
	exit 0
fi

# Make the results directory.
mkdir -p ../res/tree_likelihood_comparison/phylip

# Convert all per-locus phylip alignments to phylip format.
for fasta in ../data/fasta/*.fasta
do
    fasta_base=`basename ${fasta}`
    phylip=../res/tree_likelihood_comparison/phylip/${fasta_base%.fasta}.phy
    python3 convert.py -f phylip -g 0.2 ${fasta} ${phylip}
    echo "Wrote file ${phylip}."
done