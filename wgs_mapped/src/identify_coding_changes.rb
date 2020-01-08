# m_matschiner Wed Dec 25 20:25:55 CET 2019

# Add a function to class String to translate a codon to an amino acids using the vertebrate mitochondrial genetic code.
class String
	def to_aa
		codon = self.dup.upcase
		codon.gsub!("T","U")
		codon = codon.sub("UUU","Phe")
		codon = codon.sub("UUC","Phe")
		codon = codon.sub("UUA","Leu")
		codon = codon.sub("UUG","Leu")
		codon = codon.sub("CUU","Leu")
		codon = codon.sub("CUC","Leu")
		codon = codon.sub("CUA","Leu")
		codon = codon.sub("CUG","Leu")
		codon = codon.sub("AUU","Ile")
		codon = codon.sub("AUC","Ile")
		codon = codon.sub("AUA","Met")
		codon = codon.sub("AUG","Met")
		codon = codon.sub("GUU","Val")
		codon = codon.sub("GUC","Val")
		codon = codon.sub("GUA","Val")
		codon = codon.sub("GUG","Val")
		codon = codon.sub("UCU","Ser")
		codon = codon.sub("UCC","Ser")
		codon = codon.sub("UCA","Ser")
		codon = codon.sub("UCG","Ser")
		codon = codon.sub("CCU","Pro")
		codon = codon.sub("CCC","Pro")
		codon = codon.sub("CCA","Pro")
		codon = codon.sub("CCG","Pro")
		codon = codon.sub("ACU","Thr")
		codon = codon.sub("ACC","Thr")
		codon = codon.sub("ACA","Thr")
		codon = codon.sub("ACG","Thr")
		codon = codon.sub("GCU","Ala")
		codon = codon.sub("GCC","Ala")
		codon = codon.sub("GCA","Ala")
		codon = codon.sub("GCG","Ala")
		codon = codon.sub("UAU","Tyr")
		codon = codon.sub("UAC","Tyr")
		codon = codon.sub("UAA","***")
		codon = codon.sub("UAG","***")
		codon = codon.sub("CAU","His")
		codon = codon.sub("CAC","His")
		codon = codon.sub("CAA","Gln")
		codon = codon.sub("CAG","Gln")
		codon = codon.sub("AAU","Asn")
		codon = codon.sub("AAC","Asn")
		codon = codon.sub("AAA","Lys")
		codon = codon.sub("AAG","Lys")
		codon = codon.sub("GAU","Asp")
		codon = codon.sub("GAC","Asp")
		codon = codon.sub("GAA","Glu")
		codon = codon.sub("GAG","Glu")
		codon = codon.sub("UGU","Cys")
		codon = codon.sub("UGC","Cys")
		codon = codon.sub("UGA","Trp")
		codon = codon.sub("UGG","Trp")
		codon = codon.sub("CGU","Arg")
		codon = codon.sub("CGC","Arg")
		codon = codon.sub("CGA","Arg")
		codon = codon.sub("CGG","Arg")
		codon = codon.sub("AGU","Ser")
		codon = codon.sub("AGC","Ser")
		codon = codon.sub("AGA","***")
		codon = codon.sub("AGG","***")
		codon = codon.sub("GGU","Gly")
		codon = codon.sub("GGC","Gly")
		codon = codon.sub("GGA","Gly")
		codon = codon.sub("GGG","Gly")
		codon
	end
end

# Get the command-line arguments.
fasta_file_name = ARGV[0]
table_file_name = ARGV[1]

# Read the fasta file.
fasta_file = File.open(fasta_file_name)
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

# Make sure the sequences are correctly ordered.
unless fasta_ids[1][0..2].downcase == "mar" and fasta_ids[2][0..2].downcase == "meg"
	puts "ERROR: Fasta IDs are not as expected!"
	exit 1
end

# Identify differences among the first three sequences.
outstring = "Gene\tAA\tang\tmar\tmeg\n"
(fasta_seqs[0].size/3).times do |aa_pos|
	codon0 = fasta_seqs[0][(3*aa_pos)..((3*aa_pos)+2)]
	codon1 = fasta_seqs[1][(3*aa_pos)..((3*aa_pos)+2)]
	codon2 = fasta_seqs[2][(3*aa_pos)..((3*aa_pos)+2)]
	unless "#{codon0}#{codon1}#{codon2}".downcase.include?("n") or "#{codon0}#{codon1}#{codon2}".downcase.include?("-")
		if codon1.to_aa != codon2.to_aa
			outstring << "#{fasta_ids[0]}\t#{aa_pos+1}\t#{codon0} (#{codon0.to_aa})\t#{codon1} (#{codon1.to_aa})\t#{codon2} (#{codon2.to_aa})\n"
		end
	end
end

# Write the output file.
outfile = File.open(table_file_name,"w")
outfile.write(outstring)
