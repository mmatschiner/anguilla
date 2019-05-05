# m_matschiner Wed Jan 9 16:56:30 CET 2019

# Load modules.
module load ruby/2.1.5
module load python3/3.5.0

# Make the results directory.
mkdir -p ../res/iqtree/nexus

# Convert all per-locus phylip files to nexus format.
for phylip in ../res/tree_likelihood_comparison/phylip/*.phy
do
    phy_base=`basename ${phylip}`
    nexus=../res/iqtree/nexus/${phy_base%.phy}.nex
    if [ ! -f ${nexus} ]
    then
	python3 convert.py -f nexus ${phylip} ${nexus}
    fi
done

# Concatenate all per-locus phylip files.
concatenated=../res/iqtree/nexus/concatenated.nex
if [ ! -f ${concatenated} ]
then
    ruby concatenate.rb -i ../res/iqtree/nexus/*.nex -o ${concatenated} -f nexus -p
fi

# Make a maximum-likelihood tree with iqtree.
tree_dir=../res/iqtree/trees
mkdir -p ${tree_dir}
out=../log/iqtree/concatenated.out
rm -f ${out}
sbatch -o ${out} run_iqtree.slurm ${concatenated} ${tree_dir}
