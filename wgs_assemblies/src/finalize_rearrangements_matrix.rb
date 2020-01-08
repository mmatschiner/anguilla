# m_matschiner Wed Dec 11 23:21:21 CET 2019

# Get the command-line arguments.
rearrangements_matrix_file_name = ARGV[0]
annotation_file_name = ARGV[1]
protein_sequences_file_name = ARGV[2]
sorted_rearrangements_matrix_file_name = ARGV[3]

# Read the rearrangements matrix.
rearrangements_matrix_file = File.open(rearrangements_matrix_file_name)
rearrangements_matrix_lines = rearrangements_matrix_file.readlines

# Read the annotation file.
annotations_file = File.open(annotation_file_name)
annotations_lines = annotations_file.readlines
gene_ids = []
gene_scaffold_ids = []
gene_starts = []
gene_ends = []
annotations_lines.each do |l|
	next if l[0] == "#"
	line_ary = l.split
	if line_ary[2] == "CDS" and line_ary[5].to_f >= 0.95
		gene_ids << line_ary[-1].gsub("\"","").chomp(";")
		gene_scaffold_ids << line_ary[0]
		gene_starts << line_ary[3].to_i
		gene_ends << line_ary[4].to_i
	end
end

# Get a list of unique rearrangement locations.
location_strings = []
rearrangements_matrix_lines.each do |l|
	line_ary = l.split
	location_strings << "#{line_ary[0]}_#{line_ary[1]}_#{line_ary[2]}"
end
uniq_location_strings = location_strings.uniq

# Make sure that for each unique location string there are four lines with it.
outstring = ""
n_missing = 0
n_known = 0
n_rearrangements_reported = 0
uniq_location_strings.each do |u|
	uniq_location_lines = []
	rearrangements_matrix_lines.each do |l|
		line_ary = l.split
		location_string = "#{line_ary[0]}_#{line_ary[1]}_#{line_ary[2]}"
		if location_string == u
			uniq_location_lines << l
		end
	end
	unless uniq_location_lines.size == 4
		puts "ERROR: Expected four lines to start with '#{line_ary[0]}\t#{line_ary[1]}\t#{line_ary[2]}', but found #{uniq_location_lines.size}!"
		exit 1
	end
	states = ["X","X","X","X"]
	rearrangement_types = []
	uniq_location_lines.each do |l|
		line_ary = l.split
		states[0] = line_ary[5] if line_ary[4].include?(".jap.")
		states[1] = line_ary[5] if line_ary[4].include?(".mar.")
		states[2] = line_ary[5] if line_ary[4].include?(".meg.")
		states[3] = line_ary[5] if line_ary[4].include?(".obs.")
		rearrangement_types << line_ary[3]
	end
	if rearrangement_types.uniq.size > 1
		puts "ERROR: Found more than one rearrangement type for one location!"
		exit 1
	end
	if states.include?("X")
		puts "ERROR: Not all states could be identified!"
		exit 1
	end

	# Only analyze further and output this rearrangement if it is confirmed in at least one species.
	if states.include?("1")
		# Count the number of known and missing states.
		n_missing += states.count("N")
		n_known += states.count("0") + states.count("1")
		n_rearrangements_reported += 1

		# Compare the location with the genome annotation and calculate the distance to the nearest gene.
		uniq_location_ary = uniq_location_lines[0].split
		rearrangement_scaffold_id = uniq_location_ary[0][3..-1]
		rearrangement_start = uniq_location_ary[1].to_i
		rearrangement_end = uniq_location_ary[2].to_i
		distance_to_nearest_gene = 10000000000
		nearest_gene_id = nil
		gene_ids.size.times do |x|
			next unless gene_scaffold_ids[x] == rearrangement_scaffold_id
			distance_to_start_of_this_gene = rearrangement_start - gene_ends[x]
			distance_to_end_of_this_gene = gene_starts[x] - rearrangement_end
			distance_to_this_gene = [distance_to_start_of_this_gene,distance_to_end_of_this_gene,0].max
			if distance_to_this_gene < distance_to_nearest_gene
				distance_to_nearest_gene = distance_to_this_gene
				nearest_gene_id = gene_ids[x]
			end
		end

		# Run BLAST searches against the zebrafish proteome.
		unless distance_to_nearest_gene == 10000000000
			# Get the protein sequence for the nearest gene.
			first_annotation_line_index_this_gene = annotations_lines.index("# start gene #{nearest_gene_id}\n")
			last_annotation_line_index_this_gene = annotations_lines.index("# end gene #{nearest_gene_id}\n")
			if first_annotation_line_index_this_gene == nil or last_annotation_line_index_this_gene == nil
				puts "ERROR: Could not find annotation line!"
				exit 1
			end
			annotation_lines_this_gene = annotations_lines[first_annotation_line_index_this_gene..last_annotation_line_index_this_gene]
			protein_sequence = ""
			in_protein_sequence = false
			annotation_lines_this_gene.each do |l|
				if l[0..20] == "# protein sequence = "
					protein_sequence << l.split("=")[1].sub("[","").strip
					in_protein_sequence = true
				elsif in_protein_sequence
					in_protein_sequence = false if l.include?("]")
					protein_sequence << l.sub("# ","").sub("]","").strip
				end
			end
			if protein_sequence == ""
				puts "ERROR: Could not read protein sequence!"
				exit 1
			end
			# Write the protein sequence to a file.
			tmp_query_string = ">query\n"
			tmp_query_string << protein_sequence
			tmp_query_file = File.open("tmp.query.fasta","w")
			tmp_query_file.write(tmp_query_string)
			tmp_query_file.close
			# Run a BLAST search against the zebrafish proteosome.
			print "Running BLASTP searches for #{nearest_gene_id}..."
			blast_line=`blastp -query tmp.query.fasta -db #{protein_sequences_file_name} -culling_limit 1 -outfmt "6 sseqid evalue bitscore pident"`
			puts " done."
			if blast_line.kind_of?(Array)
				puts "ERROR: BLAST results returned as Array!"
				exit 1
			end
			unless blast_line.strip == ""
				blast_line_ary = blast_line.split
				best_blast_hit_id = blast_line_ary[0]
				best_blast_hit_evalue = blast_line_ary[1].to_f
				best_blast_hit_bitscore = blast_line_ary[2].to_i
				best_blast_hit_pident = blast_line_ary[3].to_i
				# Get the full sequence information for the best hit.
				best_blast_hit_full_id = `cat #{protein_sequences_file_name} | grep #{best_blast_hit_id}`
				best_blast_hit_full_id.match(/description:(.+$)/)
				best_blast_hit_description = $1
				best_blast_hit_description.gsub!(/\[.+\]/,"") unless best_blast_hit_description == nil
			end
		end

		# Add to the output string.
		states.map! {|s| if s == "N" then "?" else s end}
		outstring << "#{rearrangement_scaffold_id}\t#{rearrangement_start}\t#{rearrangement_end}\t#{rearrangement_types[0]}\t#{states[0]}\t#{states[1]}\t#{states[2]}\t#{states[3]}\t"
		if distance_to_nearest_gene == 10000000000
			outstring << "NA\tNA\t"
		else
			outstring << "#{distance_to_nearest_gene}\t#{nearest_gene_id}\t"
		end
		if distance_to_nearest_gene == 10000000000 or best_blast_hit_id == nil
			outstring << "NA\tNA\tNA\tNA\n"
		else
			outstring << "#{best_blast_hit_id}\t#{best_blast_hit_evalue}\t#{best_blast_hit_pident}\t#{best_blast_hit_description}\n"
		end
	end
end

# Write the output.
sorted_rearrangements_matrix_file = File.open(sorted_rearrangements_matrix_file_name,"w")
sorted_rearrangements_matrix_file.write(outstring)
puts "Wrote file #{sorted_rearrangements_matrix_file_name}."
puts "Found #{n_rearrangements_reported} rearrangements with #{n_missing} undetermined and #{n_known} determined states."
