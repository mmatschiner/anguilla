# m_matschiner Wed Apr 17 21:16:33 CEST 2019

# Load modules.
module load iqtree/1.7-beta7

# Make the results directory.
tree_dir=../res/sliding_window_phylogenies/trees
mkdir -p ${tree_dir}

# Run iqtree in sliding windows across each of the largest scaffolds.
for fasta in ../res/sliding_window_phylogenies/alignments/windows/*/*.fasta
do
    fasta_base=`basename ${fasta%.fasta}`
    scaffold=`echo ${fasta_base} | cut -d "_" -f 1`
    tree=${tree_dir}/${scaffold}/${fasta_base}.tre
    mkdir -p ${tree_dir}/${scaffold}
    if [ ! -f ${tree} ]
    then
	iqtree -s ${fasta} -o ang --quiet -pre tmp
	echo "Wrote file ${tree}."
	# Clean up.
	mv tmp.treefile ${tree}
	rm -f tmp.bionj
	rm -f tmp.ckp.gz
	rm -f tmp.iqtree
	rm -f tmp.log
	rm -f tmp.mldist
	rm -f tmp.model.gz
    fi
done