# m_matschiner Fri Dec 28 12:40:51 CET 2018

# Get the command-line arguments.
fastq_file1_name = ARGV[0]
fastq_file2_name = ARGV[1]
fastq_file3_name = ARGV[2]
outgroup_file_name = ARGV[3]
output_directory = ARGV[4]

# Read the outgroup assembly file.
print "Reading file #{outgroup_file_name}..."
STDOUT.flush
idsO = []
seqsO = []
outgroup_file = File.open(outgroup_file_name)
outgroup_lines = outgroup_file.readlines
outgroup_file.close
outgroup_lines.each do |l|
	if l[0] == ">"
		idsO << l[1..-1].strip
		seqsO << ""
	elsif l.strip != ""
		seqsO.last << l.strip
	end
end
puts " done."
STDOUT.flush

# Read the three fastq files.
print "Reading file #{fastq_file1_name}..."
STDOUT.flush
fastq_file1 = File.open(fastq_file1_name)
fastq1_lines = fastq_file1.readlines
fastq_file1.close
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
puts " done."
print "Reading file #{fastq_file2_name}..."
STDOUT.flush
fastq_file2 = File.open(fastq_file2_name)
fastq2_lines = fastq_file2.readlines
fastq_file2.close
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
puts " done."
print "Reading file #{fastq_file3_name}..."
STDOUT.flush
fastq_file3 = File.open(fastq_file3_name)
fastq3_lines = fastq_file3.readlines
fastq_file3.close
ids3 = []
seqs3 = []
fastq3_lines.each do |l|
	if l[0..3] == "@scf"
		in_seq = true
		ids3 << l[1..-1].strip
		seqs3 << ""
	elsif l[0] == "+"
		in_seq = false
	elsif in_seq
		seqs3.last << l.strip
	end
end
puts " done."

# Remove sequences that are not included in all files.
print "Removing sequences that are not in all files..."
STDOUT.flush
ids1.size.times do |x|
	unless ids2.include?(ids1[x])
		ids1[x] = nil
		seqs1[x] = nil
	end
	unless ids3.include?(ids1[x])
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
	unless ids3.include?(ids2[x])
		ids2[x] = nil
		seqs2[x] = nil
	end
end
ids2.compact!
seqs2.compact!
ids3.size.times do |x|
	unless ids1.include?(ids3[x])
		ids3[x] = nil
		seqs3[x] = nil
	end
	unless ids2.include?(ids3[x])
		ids3[x] = nil
		seqs3[x] = nil
	end
end
ids3.compact!
seqs3.compact!
puts " done."

# Remove outgroup sequences not included in all other files.
idsO.size.times do |x|
	unless ids1.include?(idsO[x])
		idsO[x] = nil
		seqsO[x] = nil
	end
end
idsO.compact!
seqsO.compact!

# Make sure that the sequence ids are identical.
unless ids1 == ids2 and ids1 == ids3 and ids1 == idsO
	puts "ERROR: The sequence identifiers differ!"
	exit 1
end

# Make sure that the sequences all have the same lengths.
print "Adjusting sequence lengths..."
STDOUT.flush
unless seqs1.size == seqs2.size and seqs1.size == seqs3.size and seqs1.size == seqsO.size
	puts "ERROR: Different numbers of sequences were found!"
	exit 1
end
seqs1.size.times do |x|
	min_length = seqs1[x].size
	min_length = seqs2[x].size if seqs2[x].size < min_length
	min_length = seqs3[x].size if seqs3[x].size < min_length
	min_length = seqsO[x].size if seqsO[x].size < min_length
	seqs1[x] = seqs1[x][0..min_length-1] if seqs1[x].size > min_length
	seqs2[x] = seqs2[x][0..min_length-1] if seqs2[x].size > min_length
	seqs3[x] = seqs3[x][0..min_length-1] if seqs3[x].size > min_length
	seqsO[x] = seqsO[x][0..min_length-1] if seqsO[x].size > min_length
end
seqs1.size.times do |x|
	unless seqs1[x].size == seqs2[x].size and seqs1[x].size == seqs3[x].size and seqs1[x].size == seqsO[x].size
		puts "ERROR: Two sequences with different lengths were found!"
		puts "Sequence #{ids1[x]} has a length of #{seqs1[x].size} bp in file #{fastq_file1_name}, but #{seqs2[x].size} in file #{fastq_file2_name}, #{seqs3[x].size} in file #{fastq_file3_name}, and #{seqsO[x].size} in file #{outgroup_file_name}."
		exit
	end
end
puts " done."

# Write fasta files for scaffolds with a length of at least 5 Mbp.
ids1.size.times do |x|
	if seqs1[x].size >= 5000000
		puts "Exporting scaffold #{ids1[x]}..."
		fasta_outstring = ""
		fasta_outstring << ">#{fastq_file1_name}\n"
		fasta_outstring << "#{seqs1[x]}\n"
		fasta_outstring << ">#{fastq_file2_name}\n"
		fasta_outstring << "#{seqs2[x]}\n"
		fasta_outstring << ">#{fastq_file3_name}\n"
		fasta_outstring << "#{seqs3[x]}\n"
		fasta_outstring << ">#{outgroup_file_name}\n"
		fasta_outstring << "#{seqsO[x]}\n"
		# Prepare the fasta output.
		fasta_file_name = "#{output_directory}/#{ids1[x]}.fasta"
		fasta_file = File.open(fasta_file_name, "w")
		fasta_file.write(fasta_outstring)
	end
end
puts " done."
