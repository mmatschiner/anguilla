# m_matschiner Sun Sep 2 12:57:00 CEST 2018

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_busy {
    n_jobs=`squeue -u michaelm | grep abba | wc -l`
    have_been_waiting=0
    while [ $n_jobs -gt 0 ]
    do
        sleep 5
	if [ ${have_been_waiting} == 0 ]
	then
	    echo -n "Waiting for resources..."
	fi
	have_been_waiting=1
        n_jobs=`squeue -u michaelm | grep abba | wc -l`
    done
    if [ ${have_been_waiting} == 1 ]
    then
	echo " done."
    fi
}

# Load modules.
module load bcftools/1.6
module load python3/3.5.0
module unload python2

# Make the results and log directories if they don't exist yet.
mkdir -p ../res/abbababa
mkdir -p ../log/abbababa
mkdir -p ../res/f4/input

# Set the input vcf file.
gzvcf_in=../data/vcf/populations.snps.rehead.filter.thin.vcf.gz
vcf_file_id=`basename ${gzvcf_in%.vcf.gz}`

# Set table names.
core_samples_table=../data/tables/core_samples.txt
all_samples_table=../data/tables/all_samples_with_mitochondrial_assignment.no_amb.txt
snapp_samples_table=../data/xml/all_species/spc.txt
missingness_table=../data/tables/anguilla_var2.allele_freqs.txt

# Get a list of samples in the vcf.
bcftools query -l ${gzvcf_in} > tmp.samples_in_vcf.txt

# Reduce the core and all samples tables to only those that are in the vcf.
cat ${core_samples_table} | grep -f tmp.samples_in_vcf.txt > tmp.core_samples_in_vcf.txt
cat ${all_samples_table} | grep -f tmp.samples_in_vcf.txt > tmp.all_samples_in_vcf.txt
rm -f tmp.samples_in_vcf.txt

# Make tables with names of samples from the four populations.
cat tmp.core_samples_in_vcf.txt | grep core_mar | cut -f 1 > tmp.core_samples_in_vcf_mar.txt
cat tmp.core_samples_in_vcf.txt | grep core_meg | cut -f 1 > tmp.core_samples_in_vcf_meg.txt
cat tmp.core_samples_in_vcf.txt | grep core_obs | cut -f 1 > tmp.core_samples_in_vcf_obs.txt
cat tmp.core_samples_in_vcf.txt | grep core_luz | cut -f 1 > tmp.core_samples_in_vcf_luz.txt
rm -f tmp.core_samples_in_vcf.txt

# Make subsets of the mar sample list according to geography.
cat tmp.all_samples_in_vcf.txt | grep mar | grep -e AFC -e AFS -e MAY -e REU | cut -f 1 > tmp.samples_in_vcf_marind.txt
cat tmp.all_samples_in_vcf.txt | grep mar | grep JAV | cut -f 1 > tmp.samples_in_vcf_marjav.txt
cat tmp.all_samples_in_vcf.txt | grep mar | grep -e PHP -e PHC -e TAI | cut -f 1 > tmp.samples_in_vcf_marssc.txt
cat tmp.all_samples_in_vcf.txt | grep mar | grep -e BOU -e SO -e VAG -e NCA -e SAW -e SAA | cut -f 1 > tmp.samples_in_vcf_marpac.txt

# Make a separate list of all samples in the vcf, replacing mar with the geography.
cat tmp.all_samples_in_vcf.txt | grep -v mar > tmp.all_samples_in_vcf.geo.txt
cat tmp.all_samples_in_vcf.txt | grep mar | grep -e AFC -e AFS -e MAY -e REU | sed "s/mar/ind/g" >> tmp.all_samples_in_vcf.geo.txt
cat tmp.all_samples_in_vcf.txt | grep mar | grep JAV | sed "s/mar/jav/g" >> tmp.all_samples_in_vcf.geo.txt
cat tmp.all_samples_in_vcf.txt | grep mar | grep -e PHP -e PHC -e TAI | sed "s/mar/ssc/g" >> tmp.all_samples_in_vcf.geo.txt
cat tmp.all_samples_in_vcf.txt | grep mar | grep -e BOU -e SO -e VAG -e NCA -e SAW -e SAA | sed "s/mar/pac/g" >> tmp.all_samples_in_vcf.geo.txt

# Make a list of the twenty most most complete samples per core population
cat ${missingness_table} | grep -f tmp.core_samples_in_vcf_mar.txt | sort -n -k5 | head -n 20 | cut -f 1 > tmp.samples_for_abba_baba_mar.txt
cat ${missingness_table} | grep -f tmp.core_samples_in_vcf_meg.txt | sort -n -k5 | head -n 20 | cut -f 1 > tmp.samples_for_abba_baba_meg.txt
cat ${missingness_table} | grep -f tmp.core_samples_in_vcf_obs.txt | sort -n -k5 | head -n 20 | cut -f 1 > tmp.samples_for_abba_baba_obs.txt
cat ${missingness_table} | grep -f tmp.core_samples_in_vcf_luz.txt | sort -n -k5 | head -n 20 | cut -f 1 > tmp.samples_for_abba_baba_luz.txt
rm -f tmp.core_samples_in_vcf*

# Make a list of the twenty most complete samples for each of the geographic mar groups.
cat ${missingness_table} | grep -f tmp.samples_in_vcf_marind.txt | sort -n -k5 | head -n 20 | cut -f 1 > tmp.samples_for_abba_baba_marind.txt
cat ${missingness_table} | grep -f tmp.samples_in_vcf_marjav.txt | sort -n -k5 | head -n 20 | cut -f 1 > tmp.samples_for_abba_baba_marjav.txt
cat ${missingness_table} | grep -f tmp.samples_in_vcf_marssc.txt | sort -n -k5 | head -n 20 | cut -f 1 > tmp.samples_for_abba_baba_marssc.txt
cat ${missingness_table} | grep -f tmp.samples_in_vcf_marpac.txt | sort -n -k5 | head -n 20 | cut -f 1 > tmp.samples_for_abba_baba_marpac.txt

# Make lists of samples of other populations.
cat tmp.all_samples_in_vcf.txt | grep bic | cut -f 1 > tmp.samples_for_abba_baba_bic.txt
cat tmp.all_samples_in_vcf.txt | grep int | cut -f 1 > tmp.samples_for_abba_baba_int.txt
cat tmp.all_samples_in_vcf.txt | grep mos | cut -f 1 > tmp.samples_for_abba_baba_mos.txt

# Make a list of all samples that will be used in the snapp analysis.
for species in "obs,bic,marind,meg" "obs,bic,marjav,meg" "obs,bic,marssc,meg" "obs,bic,marpac,meg" "obs,bic,marind,mos" "obs,bic,marjav,mos" "obs,bic,marssc,mos" "obs,bic,marpac,mos" "marind,marssc,luz,meg" "marind,marjav,luz,meg" "marind,marpac,luz,meg" "marind,marssc,luz,mos" "marind,marjav,luz,mos" "marind,marpac,luz,mos" "marpac,marssc,luz,meg" "marpac,marjav,luz,meg" "marpac,marind,luz,meg" "marpac,marssc,luz,mos" "marpac,marjav,luz,mos" "marpac,marind,luz,mos" "mar,bic,int,mos" "mar,bic,int,meg" "mar,obs,int,mos" "mar,obs,int,meg" "luz,bic,int,mos" "luz,bic,int,meg" "luz,obs,int,mos" "luz,obs,int,meg" "bic,obs,mar,int" "bic,obs,luz,int" "obs,bic,mar,int" "obs,bic,luz,int" "mar,luz,bic,int" "mar,luz,obs,int" "luz,mar,bic,int" "luz,mar,obs,int" "bic,obs,mar,meg" "bic,obs,int,meg" "bic,obs,luz,meg" "int,obs,mar,mos" "int,bic,mar,mos" "int,obs,luz,mos" "int,bic,luz,mos" "int,obs,mar,meg" "int,bic,mar,meg" "int,obs,luz,meg" "int,bic,luz,meg" "obs,int,mar,meg" "bic,int,mar,meg" "obs,int,luz,meg" "bic,int,luz,meg" "mar,luz,int,mos" "mar,luz,obs,mos" "mar,luz,bic,mos" "mar,luz,meg,mos" "mar,int,meg,mos" "mar,obs,meg,mos" "mar,bic,meg,mos" "luz,mar,int,mos" "luz,mar,obs,mos" "luz,mar,bic,mos" "luz,mar,meg,mos" "luz,int,meg,mos" "luz,obs,meg,mos" "luz,bic,meg,mos" "int,mar,meg,mos" "int,luz,obs,mos" "int,luz,bic,mos" "int,luz,meg,mos" "int,obs,meg,mos" "int,bic,meg,mos" "obs,mar,meg,mos" "obs,luz,meg,mos" "obs,int,meg,mos" "obs,bic,mar,mos" "obs,bic,luz,mos" "obs,bic,int,mos" "obs,bic,meg,mos" "bic,mar,meg,mos" "bic,luz,meg,mos" "bic,int,meg,mos" "bic,obs,mar,mos" "bic,obs,luz,mos" "bic,obs,int,mos" "bic,obs,meg,mos" "mar,luz,int,meg" "mar,luz,obs,meg" "mar,luz,bic,meg" "luz,mar,int,meg" "luz,mar,obs,meg" "luz,mar,bic,meg" "obs,bic,mar,meg" "obs,bic,luz,meg" "obs,bic,int,meg" "obs,int,luz,mos" "bic,int,luz,mos" "obs,int,mar,mos" "bic,int,mar,mos"
do
    # Feedback
    echo "Calculating abba-baba statistics for species ${species}."

    # Make sample list for this comparision.
    spc_o=`echo ${species} | cut -d "," -f 4`
    spc_p3=`echo ${species} | cut -d "," -f 3`
    spc_p2=`echo ${species} | cut -d "," -f 2`
    spc_p1=`echo ${species} | cut -d "," -f 1`
    rm -f tmp.samples_for_abba_baba.txt
    touch tmp.samples_for_abba_baba.txt
    cat tmp.samples_for_abba_baba_${spc_o}.txt | sed "s/${spc_o}/${spc_o:(-3)}/g" >> tmp.samples_for_abba_baba.txt
    cat tmp.samples_for_abba_baba_${spc_p3}.txt | sed "s/${spc_p3}/${spc_p3:(-3)}/g" >> tmp.samples_for_abba_baba.txt
    cat tmp.samples_for_abba_baba_${spc_p2}.txt | sed "s/${spc_p2}/${spc_p2:(-3)}/g" >> tmp.samples_for_abba_baba.txt
    cat tmp.samples_for_abba_baba_${spc_p1}.txt | sed "s/${spc_p1}/${spc_p1:(-3)}/g" >> tmp.samples_for_abba_baba.txt

    # Regenerate the species string using only the last three characters of each id (to turn e.g. marind into ind).
    species="${spc_p1:(-3)},${spc_p2:(-3)},${spc_p3:(-3)},${spc_o:(-3)}"

    # Make a compressed vcf file for including only the most complete samples.
    bcftools view -S tmp.samples_for_abba_baba.txt -a --min-ac=1 -O z -o tmp.vcf_for_abba_baba.vcf.gz ${gzvcf_in}
    
    # Make an uncompressed version of the same vcf file.
    bcftools view tmp.vcf_for_abba_baba.vcf.gz | grep -v "##FORMAT" | grep -v "##contig" > tmp.vcf_for_f4.vcf
    
    # Make a phylip file from the uncompressed vcf file.
    python3 vcf_to_align.py -f phylip-sequential tmp.vcf_for_f4.vcf tmp.phylip_for_f4.phy

    # Make a list linking all samples and species used for abba-baba. Use the 'geo' list in which 'mar' was replaced with ind, ssc, jav, or pac if one of the 4 species names has six characters, otherwise use the standard list.
    if [ ${#spc_o} == 6 ]
    then
	cat tmp.all_samples_in_vcf.geo.txt | grep -f tmp.samples_for_abba_baba.txt > tmp.samples_and_species_for_abba_baba.txt
    elif [ ${#spc_p3} == 6 ]
    then
	cat tmp.all_samples_in_vcf.geo.txt | grep -f tmp.samples_for_abba_baba.txt > tmp.samples_and_species_for_abba_baba.txt
    elif [ ${#spc_p2} == 6 ]
    then
	cat tmp.all_samples_in_vcf.geo.txt | grep -f tmp.samples_for_abba_baba.txt > tmp.samples_and_species_for_abba_baba.txt
    elif [ ${#spc_p1} == 6 ]
    then
	cat tmp.all_samples_in_vcf.geo.txt | grep -f tmp.samples_for_abba_baba.txt > tmp.samples_and_species_for_abba_baba.txt
    else
	cat tmp.all_samples_in_vcf.txt | grep -f tmp.samples_for_abba_baba.txt > tmp.samples_and_species_for_abba_baba.txt
    fi

    # Run abba-baba tests.
    abbababa_summary_file="../res/abbababa/${vcf_file_id}.${spc_p1}_${spc_p2}_${spc_p3}_${spc_o}.txt"
    if [ ! -f ${abbababa_summary_file} ]
    then
        out="../log/abbababa/${vcf_file_id}.${spc_p1}_${spc_p2}_${spc_p3}_${spc_o}.txt"
        rm -f ${out}
        sbatch -o ${out} calculate_abba_baba.slurm tmp.vcf_for_abba_baba.vcf.gz tmp.samples_and_species_for_abba_baba.txt ${species} ${abbababa_summary_file}
    fi

    # Wait until job is done.
    sleep_while_busy

    # Add the species id to the sample ids in the phylip file.
    while read line
    do
	phylip_sample=`echo ${line} | cut -d " " -f 1`
	phylip_sample_short=`echo ${phylip_sample} | cut -c 1-10`
	phylip_species=`echo ${line} | cut -d " " -f 2`
	cat tmp.phylip_for_f4.phy | sed "s/${phylip_sample_short}/${phylip_species}_${phylip_sample}  /g" > tmp.phylip_for_f4_2.phy
	mv -f tmp.phylip_for_f4_2.phy tmp.phylip_for_f4.phy
    done < tmp.samples_and_species_for_abba_baba.txt

    # Convert the phylip file to a treemix file.
    treemix=../res/f4/input/${vcf_file_id}.${spc_p1}_${spc_p2}_${spc_p3}_${spc_o}.txt
    python3 convert.py -p ${spc_p1:(-3)} ${spc_p2:(-3)} ${spc_p3:(-3)} ${spc_o:(-3)} -f treemix_bi tmp.phylip_for_f4.phy | grep -v "0,0" > ${treemix}

    # Clean up.
    rm -f tmp.vcf_for_abba_baba.vcf.gz
    rm -f tmp.vcf_for_f4.vcf
    rm -f tmp.phylip_for_f4.phy
    rm -f tmp.vcf_for_abba_baba.vcf
    rm tmp.samples_and_species_for_abba_baba.txt
done

# Further clean up.
rm -f tmp.samples_for_abba_baba*
rm -f tmp.all_samples_in_vcf.txt
