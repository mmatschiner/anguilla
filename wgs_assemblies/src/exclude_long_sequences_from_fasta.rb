# m_matschiner Wed Dec 4 17:13:30 CET 2019

# Get the command-line arguments.
fasta_in_file_name = ARGV[0]
minimum_length = ARGV[1].to_i
fasta_out_prefix = ARGV[2]

# Read the input file.
fasta_file = File.open(fasta_in_file_name)
id = ""
seq = ""
fasta_file.each do |l|
	if l[0] == ">"
		unless id == ""
			if seq.size >= minimum_length
				fasta_out_string = ">#{id}\n"
				while seq.size > 0
					fasta_out_string << "#{seq.slice!(0..79)}\n"
				end
				fasta_out_file_name = "#{fasta_out_prefix}#{id}.fasta"
				fasta_out_file = File.open(fasta_out_file_name,"w")
				fasta_out_file.write(fasta_out_string)
				puts "Wrote file #{fasta_out_file_name}."
			end
		end
		id = l.strip[1..-1]
		seq = ""
	else
		seq << l.strip
	end
end
if seq.size >= minimum_length
	fasta_out_string = ">#{id}\n"
	while seq.size > 0
		fasta_out_string << "#{seq.slice!(0..79)}\n"
	end
	fasta_out_file_name = "#{fasta_out_prefix}#{id}.fasta"
	fasta_out_file = File.open(fasta_out_file_name,"w")
	fasta_out_file.write(fasta_out_string)
	puts "Wrote file #{fasta_out_file_name}."
end