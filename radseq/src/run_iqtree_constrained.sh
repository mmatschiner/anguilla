# m_matschiner Sun Dec 16 01:15:02 CET 2018

# Set the prefix of constraint trees.
constraint_prefix=../data/constraints/h01

# Make the log directory.
mkdir -p ../log/iqtree/h01

# Set the alignment directory.
alignment_dir=../res/tree_likelihood_comparison/phylip

# Set the tree directory.
res_dir=../res/tree_likelihood_comparison/h01

# Make the tree directory.
mkdir -p ${res_dir}

# Run iqtree.
for last_char in {0..9}
do
for second_last_char in {0..9}
do
    out=../log/iqtree/h01/iqtree.${second_last_char}${last_char}.out
    rm -f ${out}
    sbatch -o ${out} run_iqtree_constrained.slurm ${alignment_dir} ${second_last_char} ${last_char} ${constraint_prefix} ${res_dir}
done
done
