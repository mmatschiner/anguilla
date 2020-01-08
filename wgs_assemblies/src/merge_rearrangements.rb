# m_matschiner Mon Dec 9 14:51:20 CET 2019

# Get the command-line arguments.
rearrangements_table_file_name = ARGV[0]
maximum_region_size = ARGV[1].to_i
merged_rearrangements_table_file_name = ARGV[2]

# Read the rearrangements table.
rearrangements_table_file = File.open(rearrangements_table_file_name)
rearrangements_table_lines = rearrangements_table_file.readlines

# Get the unique reference scaffolds and species ids.
ref_scaffold_ids = []
rearrangements_table_lines.each do |l|
	line_ary = l.split
	ref_scaffold_ids << line_ary[0]
end
ref_scaffold_ids.sort!.uniq!

# For each unique reference scaffold, merge overlapping rearrangements from multiple species.
outstring = ""
n_regions_written = 0
n_regions_exluded_for_size = 0
n_regions_exluded_for_mixed_types = 0
n_regions_exluded_for_negative_sizes = 0
ref_scaffold_ids.each do |s|
	# Collect information about rearrangements on this scaffold.
	other_scaffold_ids = []
	other_starts = []
	other_ends = []
	other_types = []
	rearrangements_table_lines.each do |l|
		line_ary = l.split
		if line_ary[0] == s
			other_scaffold_ids << line_ary[1]
			other_starts << line_ary[2].to_i
			other_ends << line_ary[3].to_i
			other_types << line_ary[4]
		end
	end
	# Make sure that the other end is always greater (or equal) than the other start.
	other_ends.size.times do |x|
		unless other_ends[x] >= other_starts[x]
			puts "ERROR: Found end that is smaller than start!"
			exit 1
		end
	end
	# Search for overlap among the regions of rearrangements on this scaffold.
	indices_in_all_sets = []
	other_starts.size.times do |x|
		unless indices_in_all_sets.include?(x)
			other_scaffold_ids_in_set = [other_scaffold_ids[x]]
			indices_in_all_sets << x
			indices_in_set = [x]
			this_region_start_inclusive = other_starts[x]
			this_region_end_inclusive = other_ends[x]
			this_region_start_exclusive = other_starts[x]
			this_region_end_exclusive = other_ends[x]
			this_region_types = [other_types[x]]
			overlap_found = true
			while overlap_found
				overlap_found = false
				other_starts.size.times do |y|
					unless indices_in_set.include?(y)
						overlap = true
						overlap = false if other_ends[y] < this_region_start_inclusive
						overlap = false if other_starts[y] > this_region_end_inclusive
						if overlap
							overlap_found = true
							indices_in_set << y
							indices_in_all_sets << y
							other_scaffold_ids_in_set << other_scaffold_ids[y]
							this_region_start_inclusive = [this_region_start_inclusive,other_starts[y]].min
							this_region_start_exclusive = [this_region_start_exclusive,other_starts[y]].max
							this_region_end_inclusive = [this_region_end_inclusive,other_ends[y]].max
							this_region_end_exclusive = [this_region_end_exclusive,other_ends[y]].min
							this_region_types << other_types[y]
						end
					end
				end
			end
			this_region_inclusive_size = this_region_end_inclusive-this_region_start_inclusive
			this_region_exclusive_size = this_region_end_exclusive-this_region_start_exclusive
			if this_region_exclusive_size <= maximum_region_size
				if this_region_types.uniq.size == 1
					if this_region_exclusive_size >= 0
						n_regions_written += 1
						outstring << "#{s}\t#{this_region_start_inclusive}\t#{this_region_end_inclusive}\t\t#{this_region_start_exclusive}\t#{this_region_end_exclusive}\t#{indices_in_set.size}\t"
						outstring << "#{this_region_inclusive_size}\t#{this_region_exclusive_size}\t"				
						outstring << "#{this_region_types[0]}\t"
						outstring << "["
						other_scaffold_ids_in_set.each { |o| outstring << "#{o},"}
						outstring.chomp!(",")
						outstring << "]\n"
					else
						n_regions_exluded_for_negative_sizes += 1
					end
				else
					n_regions_exluded_for_mixed_types += 1
				end
			else
				n_regions_exluded_for_size += 1
			end
		end
	end
end

# Feedback.
puts "Excluded #{n_regions_exluded_for_size} out of #{n_regions_exluded_for_size+n_regions_exluded_for_mixed_types+n_regions_exluded_for_negative_sizes+n_regions_written} regions due to their size greater than #{maximum_region_size} bp."
puts "Excluded #{n_regions_exluded_for_mixed_types} out of #{n_regions_exluded_for_mixed_types+n_regions_exluded_for_negative_sizes+n_regions_written} regions due to mixed rearrangement types."
puts "Excluded #{n_regions_exluded_for_negative_sizes} out of #{n_regions_exluded_for_negative_sizes+n_regions_written} regions due to a negative size (indicating multiple rearrangements in at least one of the species)."
puts "#{n_regions_written} regions remain."

# Write the output table.
merged_rearrangements_table_file = File.open(merged_rearrangements_table_file_name,"w")
merged_rearrangements_table_file.write(outstring)
