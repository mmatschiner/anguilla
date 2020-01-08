# m_matschiner Mon Dec 9 14:53:26 CET 2019

# Load modules.
module load ruby/2.1.5

# Set the combined rearrangements table.
table=../res/tables/rearrangements.txt

# Combine the rearrangements tables for the four different species.
cat ../res/tables/rearrangements.???.txt > ${table}

# Set the merged  table.
merged_table=../res/tables/rearrangements.merged.txt

# Set the maximum size of a region within which an inversion resides (longer regions will not be recorded).
maximum_region_size=10000

# Use a ruby script to merge rearrangements into a set of unique, potentially shared among species, rearrangements.
ruby merge_rearrangements.rb ${table} ${maximum_region_size} ${merged_table}