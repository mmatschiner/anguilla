# m_matschiner Fri Dec 28 12:40:51 CET 2018

# Get the command-line arguments.
fastq_file1_name = ARGV[0]
fastq_file2_name = ARGV[1]

# Read the two fastq files.
fastq_file1 = File.open(fastq_file1_name)
fastq1_lines = fastq_file1.readlines
in_seq = false
ids1 = []
seqs1 = []
fastq1_lines.each do |l|
	if l[0..3] == "@scf"
		in_seq = true
		ids1 << l[1..-1].strip
		seqs1 << ""
	elsif l[0] == "+"
		in_seq = false
	elsif in_seq
		seqs1.last << l.strip
	end
end
fastq_file2 = File.open(fastq_file2_name)
fastq2_lines = fastq_file2.readlines
ids2 = []
seqs2 = []
fastq2_lines.each do |l|
	if l[0..3] == "@scf"
		in_seq = true
		ids2 << l[1..-1].strip
		seqs2 << ""
	elsif l[0] == "+"
		in_seq = false
	elsif in_seq
		seqs2.last << l.strip
	end
end

# Remove sequences that are not included in the other file.
ids1.size.times do |x|
	unless ids2.include?(ids1[x])
		ids1[x] = nil
		seqs1[x] = nil
	end
end
ids1.compact!
seqs1.compact!
ids2.size.times do |x|
	unless ids1.include?(ids2[x])
		ids2[x] = nil
		seqs2[x] = nil
	end
end
ids2.compact!
seqs2.compact!

# Make sure that the sequence ids are identical.
unless ids1 == ids2
	puts "ERROR: The sequence identifiers differ!"
	exit 1
end

# Make sure that the sequences all have the same lengths.
unless seqs1.size == seqs2.size
	puts "ERROR: Different numbers of sequences were found!"
	exit 1
end
seqs1.size.times do |x|
	if seqs1[x].size > seqs2[x].size
		seqs1[x] = seqs1[x][0..seqs2[x].size-1]
	elsif seqs2[x].size > seqs1[x].size
		seqs2[x] = seqs2[x][0..seqs1[x].size-1]
	end
end
seqs1.size.times do |x|
	unless seqs1[x].size == seqs2[x].size
		puts "ERROR: Two sequences with different lengths were found!"
		puts "Sequence #{ids1[x]} has a length of #{seqs1[x].size} bp in file #{fastq_file1_name}, but #{seqs2[x].size} in file #{fastq_file2_name}."
		exit
	end
end

# Get the total sequence length.
total_length = 0
seqs1.size.times do |x|
	total_length += seqs1[x].size
end

# Feedback.
puts "Found #{seqs1.size} comparable sequences with a total (overlapping) length of #{total_length}."

# Compare the two sets of sequences.
n_comparable_sites = 0
n_substitutions = 0
seqs1.size.times do |x|
	puts "Analysing sequence #{ids1[x]}..."
	seqs1[x].size.times do |pos|
		seq1_at_pos = seqs1[x][pos].upcase
		seq2_at_pos = seqs2[x][pos].upcase
		if ["A","C","G","T"].include?(seq1_at_pos) and ["A","C","G","T"].include?(seq2_at_pos)
			n_comparable_sites += 1
			if seq1_at_pos != seq2_at_pos
				n_substitutions += 1
			end
		end
	end
end

# Report the results.
puts "Sequences #{fastq_file1_name} and #{fastq_file2_name} differ at #{n_substitutions} out of #{n_comparable_sites} comparable sites."
