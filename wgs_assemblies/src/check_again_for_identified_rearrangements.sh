# m_matschiner Wed Dec 11 11:40:35 CET 2019

# Load modules.
module load ruby/2.1.5

# Set the merged rearrangements table.
merged_table=../res/tables/rearrangements.merged.txt

# Make a list of unique reference scaffolds.
cat ${merged_table} | cut -f 1 | sort | uniq > tmp.uniq_ref_scaffolds.txt

# Make reduced maf files.
for species in jap mar meg obs
do
    maf=../res/lastz/pairwise_alignments/ang_${species}_ms1_sorted_clean.maf
    tmp_maf=tmp.${species}.maf
    if [ ! -f ${tmp_maf} ]
    then
	echo -n "Reducing file ${maf}..."
	cat ${maf} | grep -B 1 -A 1 -f tmp.uniq_ref_scaffolds.txt | tr -s " " | cut -d " " -f 1-6 > ${tmp_maf}
	echo " done."
    fi
done

# Use a ruby script to check in more detail all potential rearrangements.
minimum_search_region_size=1000
check_window_size=100000
min_score_different_id=50000
min_length_different_id=500
min_score_same_id=10000
min_length_same_id=100
ruby check_again_for_identified_rearrangements.rb ${merged_table} ${minimum_search_region_size} ${check_window_size} ${min_score_different_id} ${min_length_different_id} ${min_score_same_id} ${min_length_same_id} ../res/tables/rearrangements.matrix.txt tmp.???.maf

exit
# Clean up.
rm -f tmp.uniq_ref_scaffolds.txt
rm tmp.???.maf