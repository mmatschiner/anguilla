# m_matschiner Sun Dec 15 14:28:49 CET 2019

# Get the command-line arguments.
maf_file_name = ARGV[0]
reference_contig_id = ARGV[1]
region_start = ARGV[2].to_i
region_end = ARGV[3].to_i

# Read the maf file.
maf_file = File.open(maf_file_name)
maf_lines = maf_file.readlines
reference_alignment_starts = []
reference_alignment_ends = []
other_contigs_alignment_starts = []
other_contigs_alignment_ends = []
other_contig_ids = []
maf_lines.size.times do |x|
	line = maf_lines[x]
	unless ["--","a "].include?(line[0..1])
		line_ary = line.split
		if line_ary[1][3..-1] == reference_contig_id
			alignment_start = line_ary[2].to_i
			alignment_length = line_ary[3].to_i
			alignment_end = alignment_start + alignment_length
			overlap = true
			overlap = false if alignment_end < region_start
			overlap = false if alignment_start > region_end
			if overlap
				reference_alignment_starts << alignment_start
				reference_alignment_ends << alignment_end
				next_line_ary = maf_lines[x+1].split
				other_contig_ids << next_line_ary[1]
				other_contig_alignment_start = next_line_ary[2].to_i
				other_contig_alignment_length = next_line_ary[3].to_i
				other_contig_alignment_orientation = next_line_ary[4]
				other_contig_length = next_line_ary[5].to_i
				if other_contig_alignment_orientation == "+"
					other_contigs_alignment_starts << other_contig_alignment_start
					other_contigs_alignment_ends << other_contig_alignment_start + other_contig_alignment_length
				elsif other_contig_alignment_orientation == "-"
					other_contigs_alignment_ends << other_contig_length - other_contig_alignment_start
					other_contigs_alignment_starts << other_contig_length - other_contig_alignment_start - other_contig_alignment_length
				else
					puts "ERROR: Unexpected case!"
					exit 1
				end
			end
		end
	end
end

# Make sure that all alignment ends are larger than alignment starts.
other_contigs_alignment_starts.size.times do |x|
	if other_contigs_alignment_starts[x] >= other_contigs_alignment_ends[x]
		puts "ERROR: Alignment start is larger than alignment end!"
		exit 1
	end
end

# Report the other contig id that is most frequent in alignments within the region.
unique_other_contig_ids = other_contig_ids.uniq
if unique_other_contig_ids.size == 0
	puts "NA"
else
	if unique_other_contig_ids.size == 1
		most_frequent_other_contig_id = unique_other_contig_ids[0]
	# If multiple other contigs are present, count the bases that these have in the region.
	else
		cumulative_lengths_per_unique_other_contig = []
		unique_other_contig_ids.each do |c|
			cumulative_length = 0
			other_contig_ids.size.times do |x|
				if other_contig_ids[x] == c
					if reference_alignment_starts[x] >= region_start and reference_alignment_ends[x] <= region_end
						cumulative_length += reference_alignment_ends[x] - reference_alignment_starts[x]
					elsif reference_alignment_starts[x] < region_start and reference_alignment_ends[x] <= region_end
						cumulative_length += reference_alignment_ends[x] - region_start
					elsif reference_alignment_starts[x] >= region_start and reference_alignment_ends[x] > region_end
						cumulative_length += region_end - reference_alignment_starts[x]
					elsif reference_alignment_starts[x] < region_start and reference_alignment_ends[x] > region_end
						puts "ERROR: One contig stretches the entire region but does not seem to be the only contig!"
						exit 1
					else
						puts "ERROR: Unexpected case!"
						exit 1
					end
				end
			end
			cumulative_lengths_per_unique_other_contig << cumulative_length
		end
		most_frequent_other_contig_id = unique_other_contig_ids[cumulative_lengths_per_unique_other_contig.index(cumulative_lengths_per_unique_other_contig.max)]
	end

	# Get the smallest alignment start and the largest alignment end for this contig.
	smallest_other_alignment_start = 10000000000
	largest_other_alignment_end = 0
	other_contig_ids.size.times do |x|
		if other_contig_ids[x] == most_frequent_other_contig_id
			smallest_other_alignment_start = other_contigs_alignment_starts[x] if other_contigs_alignment_starts[x] < smallest_other_alignment_start
			largest_other_alignment_end = other_contigs_alignment_ends[x] if other_contigs_alignment_ends[x] > largest_other_alignment_end
		end
	end
	puts "#{most_frequent_other_contig_id},#{smallest_other_alignment_start},#{largest_other_alignment_end}"
end