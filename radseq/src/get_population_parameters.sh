# m_matschiner Wed Feb 20 10:28:22 CET 2019

# Define a function to sleep if too many jobs are queued or running.
function sleep_while_busy {
    n_jobs=`squeue -u michaelm | grep poppar | wc -l`
    have_been_waiting=0
    while [ $n_jobs -gt 0 ]
    do
        sleep 5
        if [ ${have_been_waiting} == 0 ]
        then
            echo -n "Waiting for resources..."
        fi
        have_been_waiting=1
        n_jobs=`squeue -u michaelm | grep poppar | wc -l`
    done
    if [ ${have_been_waiting} == 1 ]
    then
        echo " done."
    fi
}

# Ensure that the vcf file is in place.
if [ ! -f ../data/vcf/anguilla_var3.vcf.gz ]
then
    echo "Please download the file anguilla_var3.vcf.gz from the Dryad repository and place it in '../data/vcf', then restart this script."
fi

# Load modules.
module load bcftools/1.6

# Make the log directory.
mkdir -p ../log/misc

# Set the samples table.
all_samples_table=../data/tables/all_samples_with_mitochondrial_assignment.no_amb.txt

# Set the callable genome size.
callable_genome_size=18256359

# Repeat this analysis for two different vcf files.
for gzvcf in ../data/vcf/anguilla_var2.vcf.gz ../data/vcf/anguilla_var3.vcf.gz
do
	# Get the vcf id.
	vcf_id=`basename ${gzvcf%.vcf.gz}`

    # Get a list of samples in the vcf.
    bcftools query -l ${gzvcf} > tmp.samples_in_vcf.txt

    # Get population parameters for each species.
    for spc in bic int luz mar marind marjav marssc marpac meg mos obs
    do
	
	# Set the table file.
	table_file=../res/tables/${vcf_id}.${spc}.txt

	# Check if the table file already exists.
	if [ ! -f ${table_file} ]
	then

	    # Prepare list of species samples in vcf.
	    if [ ${spc} == "marind" ]
	    then
		cat ${all_samples_table} | grep mar | grep -e AFC -e AFS -e MAY -e REU | cut -f 1 > tmp.spc_samples.txt
	    elif [ ${spc} == "marjav" ]
	    then
		cat ${all_samples_table} | grep mar | grep JAV | cut -f 1 > tmp.spc_samples.txt
	    elif [ ${spc} == "marssc" ]
	    then
		cat ${all_samples_table} | grep mar | grep -e PHP -e PHC -e TAI | cut -f 1 > tmp.spc_samples.txt
	    elif [ ${spc} == "marpac" ]
	    then
		cat ${all_samples_table} | grep mar | grep -e BOU -e SO -e VAG -e NCA -e SAW -e SAA | cut -f 1 > tmp.spc_samples.txt
	    else
		cat ${all_samples_table} | grep ${spc} | cut -f 1 > tmp.spc_samples.txt
	    fi
	    cat tmp.samples_in_vcf.txt | grep -f tmp.spc_samples.txt > tmp.spc_samples_in_vcf.txt

	    # Make a vcf with only samples of this species.
	    echo -n "Making vcf subset for species ${spc}..."
	    bcftools view -S tmp.spc_samples_in_vcf.txt -o tmp.spc.vcf ${gzvcf}
	    echo " done."
    
	    # Analyze species vcf.
	    out=../log/misc/get_population_parameters.${filter}.${spc}.out
	    rm -f ${out}
	    sbatch -o ${out} get_population_parameters_from_vcf.slurm tmp.spc.vcf ${callable_genome_size} ${table_file}

	    # Wait until job is done.
	    sleep_while_busy

	    # Clean up.
	    rm -f tmp.spc.vcf
	    rm -f tmp.spc_samples.txt
	    rm -f tmp.spc_samples_in_vcf.txt

	fi

    done

    # Clean up.
    rm -f tmp.samples_in_vcf.txt

done
