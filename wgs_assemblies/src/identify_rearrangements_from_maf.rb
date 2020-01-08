# m_matschiner Thu Dec 5 15:40:41 CET 2019

# Get the command-line arguments.
maf_red_file_name = ARGV[0]
min_score = ARGV[1].to_i
min_length = ARGV[2].to_i
table_file_name = ARGV[3]

# Read the reduced maf file.
maf_red_file = File.open(maf_red_file_name)
maf_red_lines = maf_red_file.readlines

# Read the reduced maf file.
scores = []
ref_ids = []
ref_starts = []
ref_ends = []
ref_orientations = []
other_ids = []
other_starts = []
other_ends = []
other_orientations = []
first = true
n_removed_alignments = 0
n_original_alignments = 0
n_original_alignments_with_sufficient_scores = 0
maf_red_lines.size.times do |x|
	if (x/1000)*1000 == x
		puts "Reading line #{x}/#{maf_red_lines.size}..."
		STDOUT.flush
	end
	if maf_red_lines[x][0..1] == "a "
		first = true
		n_original_alignments += 1
	elsif maf_red_lines[x][0..1] == "s " and first
		score = maf_red_lines[x-1].split("=")[1].to_i
		# Only add the record if its score is sufficient.
		if score >= min_score
			ref_line_ary = maf_red_lines[x].split
			other_line_ary = maf_red_lines[x+1].split
			ref_id = ref_line_ary[1]
			ref_start = ref_line_ary[2].to_i
			ref_length = ref_line_ary[3].to_i
			# Only add the record if the length of the aligned part of the reference sequence is sufficient.
			if ref_length >= min_length
				ref_end = ref_start + ref_length
				ref_orientation = ref_line_ary[4]
				other_id = other_line_ary[1]
				other_start = other_line_ary[2].to_i
				other_length = other_line_ary[3].to_i
				other_end = other_start + other_length
				other_orientation = other_line_ary[4]
				# Only add the record if the length of the aligned part of the other sequence is sufficient.
				if other_length >= min_length
					n_original_alignments_with_sufficient_scores += 1
					scores << score
					ref_ids << ref_id
					ref_starts << ref_start
					ref_ends << ref_end
					ref_orientations << ref_orientation
					other_ids << other_id
					other_starts << other_start
					other_ends << other_end
					other_orientations << other_orientation
				end
			end
		end
		first = false
	else
		first = false
	end
end
puts " done. Removed #{n_removed_alignments} alignments out of #{n_original_alignments} (of which #{n_original_alignments_with_sufficient_scores} had sufficient score and length) due to overlaps."

# Get the unique reference scaffold ids.
uniq_ref_ids = ref_ids.uniq

# Initiate an output string.
output_string = ""

# For each unique reference id, get information about its alignments.
uniq_ref_ids.each do |s|
	# next unless s == "angscf1594"
	scores_this_scaffold = []
	ref_ids_this_scaffold = []
	ref_starts_this_scaffold = []
	ref_ends_this_scaffold = []
	ref_orientations_this_scaffold = []
	other_ids_this_scaffold = []
	other_starts_this_scaffold = []
	other_ends_this_scaffold = []
	other_orientations_this_scaffold = []
	ref_ids.size.times do |x|
		if ref_ids[x] == s
			scores_this_scaffold << scores[x]
			ref_ids_this_scaffold << ref_ids[x]
			ref_starts_this_scaffold << ref_starts[x]
			ref_ends_this_scaffold << ref_ends[x]
			ref_orientations_this_scaffold << ref_orientations[x]
			other_ids_this_scaffold << other_ids[x]
			other_starts_this_scaffold << other_starts[x]
			other_ends_this_scaffold << other_ends[x]
			other_orientations_this_scaffold << other_orientations[x]
		end
	end

	# Make sure that all reference orientations are '+'.
	unless ref_orientations_this_scaffold.uniq == ["+"]
		puts "ERROR: Expected all reference scaffold orientations to be '+' but found #{ref_orientations_this_scaffold.size} different orientations!"
		exit 1
	end

	# Make sure that the positions of reference starts is increasing.
	(ref_starts_this_scaffold.size-1).times do |x|
		unless ref_starts_this_scaffold[x] < ref_starts_this_scaffold[x+1]
			puts "ERROR: Expected reference scaffold start positions to increase but found the following:"
			puts ref_starts_this_scaffold
			exit 1
		end
	end

	# Get the unique other scaffold ids aligning to this reference scaffold.
	uniq_other_ids_this_scaffold = other_ids_this_scaffold.uniq

	# For each unique other other scaffold, check if all of its orientations are identical.
	uniq_other_ids_this_scaffold.each do |o|
		# next unless o == "japKI314924.1"
		other_orientations_this_other_scaffold = []
		other_ids_this_scaffold.size.times do |x|
			if other_ids_this_scaffold[x] == o
				other_orientations_this_other_scaffold << other_orientations_this_scaffold[x]
			end
		end
		if other_orientations_this_other_scaffold.uniq.size > 1
			# Report inversions.
			last_orientation = nil
			last_start = nil
			last_end = nil
			other_ids_this_scaffold.size.times do |x|
				if other_ids_this_scaffold[x] == o
					this_orientation = other_orientations_this_scaffold[x]
					this_start = ref_starts_this_scaffold[x]
					this_end = ref_ends_this_scaffold[x]
					if last_orientation != nil and last_orientation != this_orientation
						output_string << "#{s}\t#{o}\t#{last_end}\t#{this_start}\tinversion\n"
					end
					last_orientation = this_orientation
					last_start = this_start
					last_end = this_end
				end
			end
		end
	end

	# For each unique other scaffold, check if all of its start positions either increase or decrease.
	uniq_other_ids_this_scaffold.each do |o|
		other_starts_this_other_scaffold = []
		ref_starts_this_other_scaffold = []
		ref_ends_this_other_scaffold = []
		other_orientations_this_other_scaffold = []
		other_ids_this_scaffold.size.times do |x|
			if other_ids_this_scaffold[x] == o
				other_starts_this_other_scaffold << other_starts_this_scaffold[x]
				ref_starts_this_other_scaffold << ref_starts_this_scaffold[x]
				ref_ends_this_other_scaffold << ref_ends_this_scaffold[x]
				other_orientations_this_other_scaffold << other_orientations_this_scaffold[x]
			end
		end
		if other_starts_this_other_scaffold.size >= 2
			other_start_increments = []
			(other_starts_this_other_scaffold.size-1).times do |x|
				other_start_increments << other_starts_this_other_scaffold[x+1] - other_starts_this_other_scaffold[x]
			end
			if other_start_increments.max > 0 and other_start_increments.min < 0
				(other_starts_this_other_scaffold.size-1).times do |x|
					if other_starts_this_other_scaffold[x+1] < other_starts_this_other_scaffold[x] and other_orientations_this_other_scaffold[x] == "+" and other_orientations_this_other_scaffold[x+1] == "+"
						output_string << "#{s}\t#{o}\t#{ref_ends_this_other_scaffold[x]}\t#{ref_starts_this_other_scaffold[x+1]}\ttransposition\n"
					elsif other_starts_this_other_scaffold[x+1] < other_starts_this_other_scaffold[x] and other_orientations_this_other_scaffold[x] == "-" and other_orientations_this_other_scaffold[x+1] == "-"
						output_string << "#{s}\t#{o}\t#{ref_ends_this_other_scaffold[x]}\t#{ref_starts_this_other_scaffold[x+1]}\ttransposition\n"
					end
				end
			end
		end
	end
end

# Open the output file.
table_file = File.open(table_file_name,"w")

# Write the output file.
table_file.write(output_string)