# m_matschiner Sun Dec 16 13:37:12 CET 2018

# Load modules.
module load ruby/2.1.5

# Make the results directory.
mkdir -p ../res/plots

# Plot results for likelihood comparisons.
table=../res/tables/constrained_likelihoods_h01.txt
plot=../res/plots/constrained_likelihoods_h01.svg
ruby plot_constrained_likelihoods_bw.rb ${table} ${plot}
