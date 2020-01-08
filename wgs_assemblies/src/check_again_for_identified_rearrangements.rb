# m_matschiner Wed Dec 11 16:50:43 CET 2019

# Get the command-line arguments.
rearrangements_table_file_name = ARGV[0]
minimum_search_region_size = ARGV[1].to_i
check_window_size = ARGV[2].to_i
min_score_different_id = ARGV[3].to_i
min_length_different_id = ARGV[4].to_i
min_score_same_id = ARGV[5].to_i
min_length_same_id = ARGV[6].to_i
rearrangements_matrix_file_name = ARGV[7]
maf_red_file_names = ARGV[8..-1]

# Read the rearrangements table.
print "Reading the rearrangements table #{rearrangements_table_file_name}..."
rearrangements_table_file = File.open(rearrangements_table_file_name)
rearrangements_table_lines = rearrangements_table_file.readlines
rearrangement_ref_ids = []
rearrangement_regions_starts = []
rearrangement_regions_ends = []
rearrangement_types = []
rearrangement_identification_species = []
rearrangements_table_lines.each do |l|
	line_ary = l.split
	rearrangement_ref_ids << line_ary[0]
	rearrangement_regions_start = line_ary[3].to_i - 1 # Extend regions by 1 bp to ensure that in cases where an alignment ends right at the boundary,
	rearrangement_regions_end = line_ary[4].to_i + 1   # the next alignment is also included.
	# Extend start and end of rearrangement regions if these are below the minimum search region size. 
	rearrangement_regions_size = rearrangement_regions_end-rearrangement_regions_start
	if rearrangement_regions_size < minimum_search_region_size
		extension_size = ((minimum_search_region_size-rearrangement_regions_size)/2).to_i
		rearrangement_regions_start -= extension_size
		rearrangement_regions_end += extension_size
	end
	rearrangement_regions_starts << rearrangement_regions_start
	rearrangement_regions_ends << rearrangement_regions_end
	rearrangement_types << line_ary[8]
	spcs = []
	line_ary[9].sub("[","").sub("]","").split(",").each do |i|
		spcs << i[0..2]
	end
	rearrangement_identification_species << spcs
end
puts " done."

# Read the maf files.
scores_per_maf = []
ref_ids_per_maf = []
ref_starts_per_maf = []
ref_ends_per_maf = []
other_ids_per_maf = []
other_starts_per_maf = []
other_ends_per_maf = []
other_orientations_per_maf = []
maf_red_file_names.each do |m|
	print "Reading maf file #{m}..."
	scores_per_maf << []
	ref_ids_per_maf << []
	ref_starts_per_maf << []
	ref_ends_per_maf << []
	other_ids_per_maf << []
	other_starts_per_maf << []
	other_ends_per_maf << []
	other_orientations_per_maf << []
	maf_red_file = File.open(m)
	maf_red_lines = maf_red_file.readlines
	maf_red_lines.size.times do |x|
		if maf_red_lines[x][0..1] == "a "
			score = maf_red_lines[x].split("=")[1].to_i
			ref_line_ary = maf_red_lines[x+1].split
			other_line_ary = maf_red_lines[x+2].split
			ref_id = ref_line_ary[1]
			ref_start = ref_line_ary[2].to_i
			ref_length = ref_line_ary[3].to_i
			ref_end = ref_start + ref_length
			other_id = other_line_ary[1]
			other_start = other_line_ary[2].to_i
			other_length = other_line_ary[3].to_i
			other_end = other_start + other_length
			other_orientation = other_line_ary[4]
			scores_per_maf.last << score
			ref_ids_per_maf.last << ref_id
			ref_starts_per_maf.last << ref_start
			ref_ends_per_maf.last << ref_end
			other_ids_per_maf.last << other_id
			other_starts_per_maf.last << other_start
			other_ends_per_maf.last << other_end
			other_orientations_per_maf.last << other_orientation
		end
	end
	puts " done."
end

# Check alignments for each reference id.
outstring = ""
n_undetermined_states = 0
rearrangement_ref_ids.uniq.each do |r|
	# next unless r == "angscf1776"
	puts "Analyzing maf files for rearrangements on scaffold #{r}... done."
	# Collect information per species, for this reference id.
	scores_per_maf_this_ref_id = []
	ref_starts_per_maf_this_ref_id = []
	ref_ends_per_maf_this_ref_id = []
	other_ids_per_maf_this_ref_id = []
	other_starts_per_maf_this_ref_id = []
	other_ends_per_maf_this_ref_id = []
	other_orientations_per_maf_this_ref_id = []
	maf_red_file_names.size.times do |x|
		# Identify the maf species.
		maf_species = maf_red_file_names[x].split(".")[-2]
		scores_per_maf_this_ref_id << []
		ref_starts_per_maf_this_ref_id << []
		ref_ends_per_maf_this_ref_id << []
		other_ids_per_maf_this_ref_id << []
		other_starts_per_maf_this_ref_id << []
		other_ends_per_maf_this_ref_id << []
		other_orientations_per_maf_this_ref_id << []
		scores_per_maf[x].size.times do |y|
			if ref_ids_per_maf[x][y] == r
				scores_per_maf_this_ref_id.last << scores_per_maf[x][y]
				ref_starts_per_maf_this_ref_id.last << ref_starts_per_maf[x][y]
				ref_ends_per_maf_this_ref_id.last << ref_ends_per_maf[x][y]
				other_ids_per_maf_this_ref_id.last << other_ids_per_maf[x][y]
				other_starts_per_maf_this_ref_id.last << other_starts_per_maf[x][y]
				other_ends_per_maf_this_ref_id.last << other_ends_per_maf[x][y]
				other_orientations_per_maf_this_ref_id.last << other_orientations_per_maf[x][y]
			end
		end
		# Go through all rearrangements, but look only at those with the current reference id.
		rearrangement_ref_ids.size.times do |z|
			if rearrangement_ref_ids[z] == r
				# Collect information about alignments close to this rearrangement, only in the current species.
				rearrangement_state_this_species = "N"
				rearrangement_region_start = rearrangement_regions_starts[z]
				rearrangement_region_end = rearrangement_regions_ends[z]
				rearrangement_type = rearrangement_types[z]
				rearrangement_identification_spc = rearrangement_identification_species[z]
				scores_in_window = []
				ref_starts_in_window = []
				ref_ends_in_window = []
				other_ids_in_window = []
				other_starts_in_window = []
				other_ends_in_window = []
				other_orientations_in_window = []
				scores_per_maf_this_ref_id[x].size.times do |y|
					in_window = true
					in_window = false if ref_ends_per_maf_this_ref_id[x][y] < rearrangement_region_start - check_window_size/2
					in_window = false if ref_starts_per_maf_this_ref_id[x][y] > rearrangement_region_end + check_window_size/2
					if in_window == true and scores_per_maf_this_ref_id[x][y] >= min_score_same_id and other_ends_per_maf_this_ref_id[x][y] - other_starts_per_maf_this_ref_id[x][y] >= min_length_same_id
						scores_in_window << scores_per_maf_this_ref_id[x][y]
						ref_starts_in_window << ref_starts_per_maf_this_ref_id[x][y]
						ref_ends_in_window << ref_ends_per_maf_this_ref_id[x][y]
						other_ids_in_window << other_ids_per_maf_this_ref_id[x][y]
						other_starts_in_window << other_starts_per_maf_this_ref_id[x][y]
						other_ends_in_window << other_ends_per_maf_this_ref_id[x][y]
						other_orientations_in_window << other_orientations_per_maf_this_ref_id[x][y]
					end
				end
				# Identify the alignments closest to the start and end of the (extended) rearrangement region.
				distances_to_start = []
				scores_in_window.size.times do |w|
					if ref_starts_in_window[w] <= rearrangement_region_start and ref_ends_in_window[w] >= rearrangement_region_start
						distances_to_start << 0
					elsif ref_starts_in_window[w] < rearrangement_region_start and ref_ends_in_window[w] < rearrangement_region_start
						distances_to_start << rearrangement_region_start - ref_ends_in_window[w]
					elsif ref_starts_in_window[w] > rearrangement_region_start
						distances_to_start << 10000000000
					else
						puts "ERROR: Unexpected case!"
						exit 1
					end
				end
				distances_to_end = []
				scores_in_window.size.times do |w|
					if ref_starts_in_window[w] <= rearrangement_region_end and ref_ends_in_window[w] >= rearrangement_region_end
						distances_to_end << 0
					elsif ref_starts_in_window[w] > rearrangement_region_end and ref_ends_in_window[w] > rearrangement_region_end
						distances_to_end << ref_starts_in_window[w] - rearrangement_region_end
					elsif ref_ends_in_window[w] < rearrangement_region_end
						distances_to_end << 10000000000
					end
				end
				if distances_to_start.min < 10000000000 and distances_to_end.min < 10000000000
					closest_to_start_index = distances_to_start.index(distances_to_start.min)
					closest_to_end_index = distances_to_end.index(distances_to_end.min)
					# Make a new set of arrays for the most relevant alignments for this rearrangement (the ones closest to start and end and those inside of it).
					scores_in_focus = []
					ref_starts_in_focus = []
					ref_ends_in_focus = []
					other_ids_in_focus = []
					other_starts_in_focus = []
					other_ends_in_focus = []
					other_orientations_in_focus = []
					# Add the alignment closest to the start of the (extended) rearrangement region.
					scores_in_focus << scores_in_window[closest_to_start_index]
					ref_starts_in_focus << ref_starts_in_window[closest_to_start_index]
					ref_ends_in_focus << ref_ends_in_window[closest_to_start_index]
					other_ids_in_focus << other_ids_in_window[closest_to_start_index]
					other_starts_in_focus << other_starts_in_window[closest_to_start_index]
					other_ends_in_focus << other_ends_in_window[closest_to_start_index]
					other_orientations_in_focus << other_orientations_in_window[closest_to_start_index]
					# Check if there are any alignments inside of the (extended) rearrangement region, and if so, add them to the focus arrays.
					scores_in_window.size.times do |w|
						if ref_starts_in_window[w] > rearrangement_region_start and ref_ends_in_window[w] < rearrangement_region_end
							scores_in_focus << scores_in_window[w]
							ref_starts_in_focus << ref_starts_in_window[w]
							ref_ends_in_focus << ref_ends_in_window[w]
							other_ids_in_focus << other_ids_in_window[w]
							other_starts_in_focus << other_starts_in_window[w]
							other_ends_in_focus << other_ends_in_window[w]
							other_orientations_in_focus << other_orientations_in_window[w]
						end
					end
					# Add the alignment closest to the end of the (extended) rearrangement region.
					scores_in_focus << scores_in_window[closest_to_end_index]
					ref_starts_in_focus << ref_starts_in_window[closest_to_end_index]
					ref_ends_in_focus << ref_ends_in_window[closest_to_end_index]
					other_ids_in_focus << other_ids_in_window[closest_to_end_index]
					other_starts_in_focus << other_starts_in_window[closest_to_end_index]
					other_ends_in_focus << other_ends_in_window[closest_to_end_index]
					other_orientations_in_focus << other_orientations_in_window[closest_to_end_index]
					# Check if all alignments in the focus region have the same other id.
					if other_ids_in_focus.uniq.size == 1
						# If there is a single scaffold crossing from start to end of the rearrangement region, set the rearrangement to be absent.
						if other_ids_in_focus.size == 1
							rearrangement_state_this_species = "0"
						# If there are multiple scaffolds between start and end of the rearrangement region, set the rearrangement to be absent if
						# 1) all scaffolds have the same id.
						# 2) there are only short gaps between them (using min_length_different_id as threshold).
						#    The use of min_length_different_id here is a bit arbitrary, but I assume that the lengths used for it are appropriate.
						else
							longest_gap_length = 0
							(other_ids_in_focus.size-1).times do |p|
								gap_length = ref_starts_in_focus[p+1] - ref_ends_in_focus[p]
								longest_gap_length = gap_length if gap_length > longest_gap_length
							end
							if longest_gap_length < min_length_different_id
								rearrangement_state_this_species = "0"
							end
						end
						if rearrangement_type == "inversion"
							rearrangement_state_this_species = "1" if other_orientations_in_focus.uniq.size > 1
						elsif rearrangement_type == "transposition"
							0.upto(scores_in_focus.size-2) do |f|
								if other_starts_in_focus[f] > other_starts_in_focus[f+1]
									rearrangement_state_this_species = "1"
									# puts "INFO: #{rearrangement_type} on scaffold #{r} in region #{rearrangement_region_start}-#{rearrangement_region_end}  (maf: #{maf_species})."
									# puts "other_starts_in_focus[f]: #{other_starts_in_focus[f]}"
									# puts "other_starts_in_focus[f+1]: #{other_starts_in_focus[f+1]}"
									break
								end
							end
						end
					# If the other ids differ, check if the first and last are identical.
					elsif other_ids_in_focus[0] == other_ids_in_focus[-1]
						# To ignore short alignments of secondary other ids, remove these if they are short and have low scores.
						scores_in_focus.size.times do |u|
							unless other_ids_in_focus[u] == other_ids_in_focus[0]
								if other_ends_in_focus[u] - other_starts_in_focus[u] < min_length_different_id or scores_in_focus[u] < min_score_different_id
									scores_in_focus[u] = nil
									ref_starts_in_focus[u] = nil
									ref_ends_in_focus[u] = nil
									other_ids_in_focus[u] = nil
									other_starts_in_focus[u] = nil
									other_ends_in_focus[u] = nil
									other_orientations_in_focus[u] = nil
								end
							end
						end
						scores_in_focus.compact!
						ref_starts_in_focus.compact!
						ref_ends_in_focus.compact!
						other_ids_in_focus.compact!
						other_starts_in_focus.compact!
						other_ends_in_focus.compact!
						other_orientations_in_focus.compact!
						if other_ids_in_focus.uniq.size == 1
							if other_ids_in_focus.size == 1
								rearrangement_state_this_species = "0"
							# If there are multiple scaffolds between start and end of the rearrangement region, set the rearrangement to be absent if
							# 1) all scaffolds have the same id.
							# 2) there are only short gaps between them (using min_length_different_id as threshold).
							#    The use of min_length_different_id here is a bit arbitrary, but I assume that the lengths used for it are appropriate.
							else
								longest_gap_length = 0
								(other_ids_in_focus.size-1).times do |p|
									gap_length = ref_starts_in_focus[p+1] - ref_ends_in_focus[p]
									longest_gap_length = gap_length if gap_length > longest_gap_length
								end
								if longest_gap_length < min_length_different_id
									rearrangement_state_this_species = "0"
								end
							end
							if rearrangement_type == "inversion"
								rearrangement_state_this_species = "1" if other_orientations_in_focus.uniq.size > 1
							elsif rearrangement_type == "transposition"
								0.upto(scores_in_focus.size-2) do |f|
									if other_starts_in_focus[f] > other_starts_in_focus[f+1]
										rearrangement_state_this_species = "1"
										# puts "INFO: #{rearrangement_type} on scaffold #{r} in region #{rearrangement_region_start}-#{rearrangement_region_end}  (maf: #{maf_species})."
										# puts "other_starts_in_focus[f]: #{other_starts_in_focus[f]}"
										# puts "other_starts_in_focus[f+1]: #{other_starts_in_focus[f+1]}"
										break
									end
								end
							end
						else
							# Report information about unexpected other ids in between.
							secondary_other_ids_in_focus = []
							secondary_scores_in_focus = []
							secondary_lengths_in_focus = []
							scores_in_focus.size.times do |u|
								unless other_ids_in_focus[u] == other_ids_in_focus[0]
									secondary_other_ids_in_focus << other_ids_in_focus[u]
									secondary_scores_in_focus << scores_in_focus[u]
									secondary_lengths_in_focus << other_ends_in_focus[u] - other_starts_in_focus[u]
								end
							end
							if secondary_other_ids_in_focus.size == 1
								puts "WARNING: 1 unexpected other id (id: #{secondary_other_ids_in_focus[0]}; score: #{secondary_scores_in_focus[0]}; length: #{secondary_lengths_in_focus[0]}) for #{rearrangement_type} on scaffold #{r} in region #{rearrangement_region_start}-#{rearrangement_region_end}  (maf: #{maf_species})."
							else
								puts "WARNING: #{secondary_other_ids_in_focus.size} unexpected other ids (scores: #{secondary_scores_in_focus.min}-#{secondary_scores_in_focus.max}; lengths: #{secondary_lengths_in_focus.min}-#{secondary_lengths_in_focus.max}) for #{rearrangement_type} on scaffold #{r} in region #{rearrangement_region_start}-#{rearrangement_region_end}  (maf: #{maf_species})."
							end
						end
					elsif rearrangement_identification_species.include?(maf_species)
						puts "ERROR: First and last other ids in focus region differ for #{rearrangement_type} on scaffold #{r} in region #{rearrangement_region_start}-#{rearrangement_region_end} (maf: #{maf_species})!"
						exit 1
					end
				else
					if distances_to_start.min == 10000000000
						puts "WARNING: No scaffold found within the window that is before the start of #{rearrangement_type} on scaffold #{r} in region #{rearrangement_region_start}-#{rearrangement_region_end}  (maf: #{maf_species})."
					elsif distances_to_end.min == 10000000000
						puts "WARNING: No scaffold found within the window that is after the end of #{rearrangement_type} on scaffold #{r} in region #{rearrangement_region_start}-#{rearrangement_region_end}  (maf: #{maf_species})."
					else
						puts "ERROR: Unexpected case!"
						exit 1
					end
				end
				# Add the rearrangement state to the output string.
				outstring << "#{r}\t#{rearrangement_region_start}\t#{rearrangement_region_end}\t#{rearrangement_type}\t#{maf_red_file_names[x]}\t#{rearrangement_state_this_species}\n"
				n_undetermined_states += 1 if rearrangement_state_this_species == "N"
			end
		end
	end
end

# Write the output file.
rearrangements_matrix_file = File.open(rearrangements_matrix_file_name,"w")
rearrangements_matrix_file.write(outstring)
puts "Wrote file #{rearrangements_matrix_file_name}."
puts "#{n_undetermined_states} states are undetermined."