# m_matschiner Thu Dec 5 16:00:04 CET 2019

# Set the account.
acct=nn9244k

# Make the output directory.
mkdir -p ../res/tables

# Make the log directory.
mkdir -p ../log/misc

# Set the minimum score and length of alingments.
min_score=50000
min_length=1000

# Get rearrangements between ang and the four other species.
for species in jap mar meg obs
do
    # Set the maf file.
    maf=../res/lastz/pairwise_alignments/ang_${species}_ms1_sorted_clean.maf

    # Set the table file.
    table=../res/tables/rearrangements.${species}.txt

    # Check if the table file has been written already.
    if [ ! -f ${table} ]
    then
	# Set the log file.
	out=../log/misc/identify_rearrangements.${species}.out
	rm -f ${out}

	# Launch a job to run a ruby script to identify rearrangements.
	sbatch --account nn9244k -o ${out} identify_rearrangements_from_maf.slurm ${maf} ${min_score} ${min_length} ${table}
    fi
done