# m_matschiner Thu Nov 8 19:26:06 CET 2018

# Load FileUtils (needed to recursively make directories).
require 'fileutils'

# Get the command line arguments.
alignment_directory_in = ARGV[0].chomp("/")
alignment_directory_out = ARGV[1].chomp("/")

# Create the output directory if they don't exist yet.
FileUtils.mkdir_p(alignment_directory_out) unless Dir.exists?(alignment_directory_out)

# Collect names of fasta files in the input directory.
dir_entries_in = Dir.entries(alignment_directory_in)
filenames_in = []
dir_entries_in.each {|e| filenames_in << e if e.match(/.*\.fasta/)}

# Initiate arrays for the ids and sequences of each alignment.
fasta_ids_per_alignment = []
fasta_seqs_per_alignment = []

# Do for each fasta file in the input directory.
filenames_in.each do |f|

	# Read the fasta file.
	fasta_file = File.open("#{alignment_directory_in}/#{f}")
	fasta_lines = fasta_file.readlines
	fasta_ids = []
	fasta_seqs = []
	fasta_lines.each do |l|
		if l[0] == ">"
			fasta_ids << l[1..-1].strip
			fasta_seqs << ""
		elsif l.strip != ""
			fasta_seqs.last << l.strip
		end
	end
	fasta_ids_per_alignment << fasta_ids
	fasta_seqs_per_alignment << fasta_seqs
end

# Make sure the ids are identical in all alignments.
fasta_ids_per_alignment[1..-1].each do |ids|
	raise "Ids differ between alignments!" if ids != fasta_ids_per_alignment[0]
end

# Prepare a concatenated alignment.
concatenated_seqs = []
fasta_ids_per_alignment[0].size.times do |x|
	concatenated_seqs << ""
	fasta_seqs_per_alignment.each do |s|
		concatenated_seqs.last << s[x]
	end
end

# Split the concatenated alignment according to codon position.
concatenated_cp1_seqs = []
concatenated_cp2_seqs = []
concatenated_seqs.each do |s|
	concatenated_cp1_seqs << ""
	concatenated_cp2_seqs << ""
	s.size.times do |x|
		if (x/2)*2 == x
			concatenated_cp1_seqs.last << s[x]
		else
			concatenated_cp2_seqs.last << s[x]
		end
	end
end

# Prepare the string for two concatenated fasta files, one for each codon position.
concatenated_cp1_string = "#nexus\n"
concatenated_cp1_string << "\n"
concatenated_cp1_string << "begin data;\n"
concatenated_cp1_string << "dimensions  ntax=#{fasta_ids_per_alignment[0].size} nchar=#{concatenated_cp1_seqs[0].size};\n"
concatenated_cp1_string << "format datatype=DNA gap=- missing=?;\n"
concatenated_cp1_string << "matrix\n"
fasta_ids_per_alignment[0].size.times do |x|
    concatenated_cp1_string << "#{fasta_ids_per_alignment[0][x].ljust(12)}#{concatenated_cp1_seqs[x]}\n"
end
concatenated_cp1_string << ";\n"
concatenated_cp1_string << "end;\n"
concatenated_cp2_string = "#nexus\n"
concatenated_cp2_string << "\n"
concatenated_cp2_string << "begin data;\n"
concatenated_cp2_string << "dimensions  ntax=#{fasta_ids_per_alignment[0].size} nchar=#{concatenated_cp2_seqs[0].size};\n"
concatenated_cp2_string << "format datatype=DNA gap=- missing=?;\n"
concatenated_cp2_string << "matrix\n"
fasta_ids_per_alignment[0].size.times do |x|
    concatenated_cp2_string << "#{fasta_ids_per_alignment[0][x].ljust(12)}#{concatenated_cp2_seqs[x]}\n"
end
concatenated_cp2_string << ";\n"
concatenated_cp2_string << "end;\n"

# Write the fasta files.
concatenated_cp1_file_name = "#{alignment_directory_out}/concatenated_cp1.nex"
concatenated_cp1_file = File.open(concatenated_cp1_file_name,"w")
concatenated_cp1_file.write(concatenated_cp1_string)
concatenated_cp2_file_name = "#{alignment_directory_out}/concatenated_cp2.nex"
concatenated_cp2_file = File.open(concatenated_cp2_file_name,"w")
concatenated_cp2_file.write(concatenated_cp2_string)
