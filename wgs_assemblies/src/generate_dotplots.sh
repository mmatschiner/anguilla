# m_matschiner Sun Dec 15 13:31:30 CET 2019

# Load the Ruby module.
module load ruby/2.1.5

# Set the newline symbol the be the only separator (otherwise tabs in the file will separate items).
IFS=$'\n'
set -f

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/dotplots

# Set the rearrangements table file.
table=../res/tables/rearrangements.matrix.finalized.txt 

# Read the rearrangement table line by line.
while read line
do
    # Get parameters from the line.
    spc1_id="ang"
    spc1_contig=`echo ${line} | cut -f 1`
    spc1_start=`echo ${line} | cut -f 2`
    spc1_end=`echo ${line} | cut -f 3`
    for spc2_id in jap mar meg obs
    do
	# Set the maf file.
	tmp_maf=tmp.${spc2_id}.maf

	# Make the temporary reduced maf file if it doesn't exist yet.
	if [ ! -f ${tmp_maf} ]
	then
	    echo -n "Reducing file ${maf}..."
	    maf=../res/lastz/pairwise_alignments/ang_${spc2_id}_ms1_sorted_clean.maf
	    merged_table=../res/tables/rearrangements.merged.txt
	    cat ${merged_table} | cut -f 1 | sort | uniq > tmp.uniq_ref_scaffolds.txt
            cat ${maf} | grep -B 1 -A 1 -f tmp.uniq_ref_scaffolds.txt | tr -s " " | cut -d " " -f 1-6 > ${tmp_maf}
            echo " done."
	fi

	# Use a ruby script to determine the most frequent contig in alignments in the focus region.
	echo -n "Determining the ${spc2_id} contig most frequently aligning to the rearrangement region ${spc1_start}-${spc1_end} on ${spc1_id} scaffold ${spc1_contig}..."
	spc2_contig_start_end_string=`ruby get_most_frequent_contig_in_region_from_maf.rb ${tmp_maf} ${spc1_contig} ${spc1_start} ${spc1_end}`
	echo " done. Returned string is ${spc2_contig_start_end_string}."
	
	# Check if any contig id is found.
	if [ ${spc2_contig_start_end_string} != "NA" ]
	then
	    spc2_contig=`echo ${spc2_contig_start_end_string} | cut -d "," -f 1`
	    spc2_start=`echo ${spc2_contig_start_end_string} | cut -d "," -f 2`
	    spc2_end=`echo ${spc2_contig_start_end_string} | cut -d "," -f 3`

	    # Remove species_ids from contig ids.
	    spc2_contig=${spc2_contig:3:${#spc2_contig}-1}

	    # Extend the focus region by 500 bp in both directions.
	    extended_spc1_start="$((${spc1_start}-500))"
	    extended_spc1_end="$((${spc1_end}+500))"
            extended_spc2_start="$((${spc2_start}-500))"
            extended_spc2_end="$((${spc2_end}+500))"
	    if (( ${extended_spc1_start} < 1 ))
	    then
		extended_spc1_start=1
	    fi
	    if (( ${extended_spc2_start} < 1 ))
            then
                extended_spc2_start=1
            fi

	    # Set the plot id.
	    plot_id="${spc1_id}_${spc1_contig}_${spc1_start}_${spc1_end}_${spc2_id}_${spc2_contig%_pilon}"

	    # Determine the assembly files.
	    if [ ${spc1_id} == "ang" ]
	    then
		spc1_fasta=../data/assemblies/angang.fasta.masked
		gff=../data/assemblies/augustus.gff
	    else
		echo "ERROR: Expected the first species to be angang."
		exit 1
	    fi
	    if [ ${spc2_id} == "jap" ]
	    then
		spc2_fasta=../data/assemblies/angjap.fasta.masked
	    else
		spc2_fasta=../data/assemblies/${spc2_id}_pilon.fasta.masked
	    fi
	    # Check if the dotplot file already exists.
	    if [ ! -f ../res/dotplots/${plot_id}.svg ]
	    then
		# Get the contig sequences from the assemlies.
		echo -n "Extracting contig sequences from assemblies..."
		./fastagrep -t -p ${spc1_contig} ${spc1_fasta} > tmp.spc1.fasta
		./fastagrep -t -p ${spc2_contig} ${spc2_fasta} > tmp.spc2.fasta
		echo " done."
		# Generate dot plots.
		ruby generate_dot_plot.rb -s tmp.spc1.fasta -f ${extended_spc1_start} -l ${extended_spc1_end} -r tmp.spc2.fasta -p ${extended_spc2_start} -q ${extended_spc2_end} -g ${gff} -t 11 -c 0.1 -o ../res/dotplots/${plot_id}.svg
	    fi
	fi
    done
done < ${table}

# Clean up.
rm -f tmp.spc{1,2}.fasta
