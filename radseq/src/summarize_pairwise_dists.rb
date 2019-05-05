# m_matschiner Thu Mar 14 23:41:06 CET 2019

# Get the command-line arguments.
pairwise_dists_file_name = ARGV[0]
species_table_file_name = ARGV[1]
output_table_file_name = ARGV[2]

# Read the species table.
species_table_file = File.open(species_table_file_name)
species_table_lines = species_table_file.readlines
specimen_ids = []
species_names = []
species_table_lines.each do |l|
	line_ary = l.split
	specimen_ids << line_ary[0]
	species_names << line_ary[1]
end

# Get the unique species names.
uniq_species_names = species_names.uniq

# Read the pairwise distances file.
pairwise_dists_file = File.open(pairwise_dists_file_name)
pairwise_dists_lines = pairwise_dists_file.readlines
pairwise_dists_specimen_names1 = []
pairwise_dists_specimen_names2 = []
pairwise_dists = []
pairwise_dists_lines.each do |l|
	line_ary = l.split
	pairwise_dists_specimen_names1 << line_ary[0]
	pairwise_dists_specimen_names2 << line_ary[1]
	pairwise_dists << line_ary[5].to_f
end

# Get the mean distance for each pairwise comparison of unique species names.
outstring = ""
0.upto(uniq_species_names.size-2) do |s1|
	specimen_ids1 = []
	specimen_ids.size.times do |x|
		specimen_ids1 << specimen_ids[x] if species_names[x] == uniq_species_names[s1]
	end
	(s1+1).upto(uniq_species_names.size-1) do |s2|
		dist_sum = 0
		dist_count = 0
		specimen_ids2 = []
		specimen_ids.size.times do |x|
			specimen_ids2 << specimen_ids[x] if species_names[x] == uniq_species_names[s2]
		end
		pairwise_dists_specimen_names1.size.times do |x|
			if specimen_ids1.include?(pairwise_dists_specimen_names1[x]) and specimen_ids2.include?(pairwise_dists_specimen_names2[x])
				dist_sum += pairwise_dists[x]
				dist_count += 1
			elsif specimen_ids2.include?(pairwise_dists_specimen_names1[x]) and specimen_ids1.include?(pairwise_dists_specimen_names2[x])
				dist_sum += pairwise_dists[x]
				dist_count += 1
			end
		end
		outstring << "#{uniq_species_names[s1]}\t#{uniq_species_names[s2]}\t#{dist_count}\t#{dist_sum/dist_count.to_f}\n"
	end
end

# Write the output.
output_table_file = File.open(output_table_file_name, "w")
output_table_file.write(outstring)
