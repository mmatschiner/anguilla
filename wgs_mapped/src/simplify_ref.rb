# m_matschiner Fri Sep 21 10:06:03 CEST 2018

# Get the command-line arguments.
in_fasta_name=ARGV[0]
out_fasta_name=ARGV[1]

# Read the input fasta file.
in_fasta=File.open(in_fasta_name)
in_lines = in_fasta.readlines
out_string = ""
in_lines.each do |l|
	if l[0] == ">"
		out_string << ">scf#{l.split("_")[2].rjust(4).gsub(" ","0")}\n"
	else
		out_string << l
	end
end

# Write the output string.
out_fasta = File.open(out_fasta_name, "w")
out_fasta.write(out_string)