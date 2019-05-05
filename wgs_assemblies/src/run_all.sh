# m_matschiner Thu Nov 8 17:59:15 CET 2018

# Download the assembly files.
bash get_subjects.sh

# Make blast databases for all assemblies.
bash make_blast_dbs.sh

# Use blast searches to find orthologs for queries.
bash find_orthologs.sh

# Filter sequences in alignments in directory 01 by bitscores.
bash filter_sequences_by_bitscore.sh

# Filter sites in alignments in directory 02 with BMGE.
bash filter_sites_with_BMGE.sh

# Filter exon alignments in directory 03 by missing data (no missing sequences, minimum length 150 bp).
bash filter_exons_by_missing_data.sh

# Filter sites in directory 04 by removing all third-codon positions.
bash filter_sites_by_codon_position.sh

# Filter exon alignments in directory 05 by gc content.
bash filter_exons_by_GC_content_variation.sh

# Filter genes in directory 06 by exon number.
bash filter_genes_by_exon_number.sh

# Exclude genes in directory 07 that were not included in musilova et al. 2018.
bash exclude_genes_not_used_previously.sh 

# Concatenate the genes in directory 08 by codon position.
bash concatenate_per_cp.sh

# Manually prepare the xml file with beauti.
echo "Note that the file 'eel_assemblies.xml' in '../data/xml' was prepared manually (using BEAUti) based on the generated alignments in the results directory."

# Run beast.
run_beast.sh