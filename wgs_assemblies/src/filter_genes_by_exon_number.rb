# m_matschiner Tue Sep 18 09:40:27 CEST 2018

# Get the command line arguments.
alignment_directory_in = ARGV[0].chomp("/")
alignment_directory_out = ARGV[1].chomp("/")
exons_info_file_name = ARGV[2]
minimum_number_of_exons_per_gene = ARGV[3].to_i

# Collect names of nucleotide fasta files in the input directory.
dir_entries_in = Dir.entries(alignment_directory_in)
filenames_in = []
dir_entries_in.each {|e| filenames_in << e if e.match(/.*_nucl.fasta/)}

# Get exon names of alignments from the filenames.
exon_alignment_names = []
filenames_in.each do |f|
	exon_alignment_names << f.chomp("_nucl.fasta")
end

# Read the exons info file.
exons_info_file = File.open(exons_info_file_name)
exons_info_lines = exons_info_file.readlines
exon_ids = []
gene_ids = []
exon_chromosome_ids = []
exon_froms = []
exon_tos = []
exons_info_lines[1..-1].each do |l|
	exon_ids << l.split[0]
	gene_ids << l.split[1]
end
unique_gene_ids = gene_ids.uniq

# For each gene, test whether at least three exons alignments are still present.
count = 0
n_dirs_generated = 0
unique_gene_ids.each do |g|
	# Feedback.
	count += 1
	print "Analyzing gene #{g}..."
	exon_ids_for_this_gene = []
	gene_ids.size.times do |x|
		if gene_ids[x] == g and exon_alignment_names.include?(exon_ids[x])
			exon_ids_for_this_gene << exon_ids[x]
		end
	end
	# If the minimum number of exon alignments is still present, convert the fasta
	# alignment files to nexus format and save these in a directory inside the
	# alignments output directory.
	if exon_ids_for_this_gene.size >= minimum_number_of_exons_per_gene
		Dir.mkdir("#{alignment_directory_out}/#{g}")
		n_dirs_generated += 1
		fasta_concatenated_ids = []
		fasta_concatenated_seqs = []
		exon_ids_for_this_gene.each do |e|
			# Read the input fasta file.
			fasta_in_file_name = "#{e}_nucl.fasta"
			fasta_in_file = File.open("#{alignment_directory_in}/#{fasta_in_file_name}")
			fasta_in_lines = fasta_in_file.readlines
			fasta_in_ids = []
			fasta_in_seqs = []
			fasta_in_lines.each do |l|
				if l[0] == ">"
					fasta_in_ids << l[1..-1].strip[0..5]
					fasta_in_seqs << ""
				elsif l.strip != ""
					fasta_in_seqs.last << l.strip
				end
			end
			# Make sure that the sequence ids are identical in all alignments.
			if fasta_concatenated_ids == []
				fasta_concatenated_ids = fasta_in_ids
				fasta_concatenated_ids.each { fasta_concatenated_seqs << "" }
			elsif fasta_concatenated_ids != fasta_in_ids
				puts "ERROR: Sequence IDs appear to differ between alignment files!"
				exit 1
			end
			fasta_in_seqs.size.times { |x| fasta_concatenated_seqs[x] << fasta_in_seqs[x] }
		end
		# # Prepare the fasta output string for this exon.
		# fasta_out_string = ""
		# fasta_in_ids.size.times do |x|
		# 	fasta_out_string << ">#{fasta_in_ids[x]}\n"
		# 	fasta_out_string << "#{fasta_in_seqs[x]}\n"
		# end
		# # Write the fasta file with the alignment for this exon.
		# fasta_out_file_name = "#{e}.fasta"
		# fasta_out_file = File.open("#{alignment_directory_out}/#{g}/#{fasta_out_file_name}","w")
		# fasta_out_file.write(fasta_out_string)
		# Prepare the fasta output string for an alignment concatenating all genes.
		fasta_concatenated_string = ""
		fasta_concatenated_ids.size.times do |x|
			fasta_concatenated_string << ">#{fasta_concatenated_ids[x]}\n"
			fasta_concatenated_string << "#{fasta_concatenated_seqs[x]}\n"
		end
		# Write the fasta file with the alignment concatenating all genes.
		fasta_concatenated_file_name = "#{g}.fasta"
		fasta_concatenated_file = File.open("#{alignment_directory_out}/#{g}/#{fasta_concatenated_file_name}","w")
		fasta_concatenated_file.write(fasta_concatenated_string)
		puts " done."
	else
		puts " done. Too few exons for this gene."
	end
end

# Feedback.
puts "#{n_dirs_generated} out of #{unique_gene_ids.size} genes remain after filtering."
