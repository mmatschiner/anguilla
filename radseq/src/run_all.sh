# m_matschiner Sun Sep 2 12:51:12 CEST 2018

# Simplify the sequence names of the anguilla anguilla reference genome.
bash simplify_ref.sh

# Thin the vcf with vcftools.
bash thin_vcf.sh

# Paint ancestry at fixed sites.
bash paint_ancestry.sh

# Prepare snapp xmls file with snapp_prep.rb.
bash prepare_snapp_xmls.sh

# Run the snapp analyses (repeat this 16 times).
bash run_snapp.sh
echo "Note that this command will need to be repeated 16 times to resume the snapp analyses."
exit 0

# Combine the posterior distributions of snapp analyses.
bash combine_snapp_results.sh

# Run abba-baba tests for several comparisons.
bash calculate_abba_baba.sh

# Run the f4 script for the same comparisons.
bash run_f4.sh

# Summarize abba-baba and f4 results.
bash summarize_introgression_stats.sh

# Convert fasta alignments to phylip format for iqtree analyses.
bash convert_locus_alignments_to_phylip.sh

# Generate ml phylogenies with three different constraints for each locus with iqtree.
bash run_iqtree_constrained.sh

# Summarize the likelihoods of the three different hypotheses.
bash summarize_constrained_iqtree_analyses.sh

# Plot the differences between the best and second-best likelihood, per best-supported hypothesis.
bash plot_constrained_likelihoods.sh

# Run an iqtree analysis for concatenated loci, including calculation of concordance factors.
bash run_iqtree_concatenated.sh

# Calculate pairwise distances between species.
bash get_pairwise_dists.sh

# Calculate population-genetic parameters.
bash get_population_parameters.sh