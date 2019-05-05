# m_matschiner Wed Apr 17 16:08:01 CEST 2019

# Shorten the sequence ids in the reference file.
bash simplify_ref.sh

# Calculate pairwise distances in order to estimate mutation rates for psmc.
bash count_mutations_between_fastqs.sh

# Calculate the d statistic for the species quartet with the three wgs species and a. anguilla.
bash calculate_abba_baba_from_eel_assemblies.sh

# Prepare alignments in fasta format for the largest scaffolds.
bash make_alignments_for_largest_scaffolds.sh

# Make maximum-likelihood phylogenies for all sliding windows with iqtree.
bash run_iqtree_for_sliding_windows.sh

# Summarize the results of iqtree analyses.
bash summarize_iqtree_trees.sh