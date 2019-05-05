#!/bin/bash

# m_matschiner Sun Sep 2 13:04:25 CEST 2018

# Job name:
#SBATCH --job-name=abba
#
# Wall clock limit:
#SBATCH --time=24:00:00
#
# Processor and memory usage:
#SBATCH --mem-per-cpu=30G

## Set up the job environment.
source /cluster/bin/jobsetup
module load python2/2.7.10
module load bcftools/1.6
module load R/3.4.4
module unload python3

## Feedback.
echo
echo "calculate_abba_baba.slurm was called with arguments ${@}."
echo

# Get the command-line arguments.
gzvcf_with_relative_path=${1}
gzvcf_with_absolute_path=`readlink -f ${gzvcf_with_relative_path}`
file_id=`basename ${gzvcf_with_relative_path%.vcf.gz}`
gzvcf=`basename ${gzvcf_with_absolute_path}`
sample_table_with_relative_path=${2}
sample_table_with_absolute_path=`readlink -f ${sample_table_with_relative_path}`
species=${3}
spc_o=`echo ${species} | cut -d "," -f 4`
spc_p3=`echo ${species} | cut -d "," -f 3`
spc_p2=`echo ${species} | cut -d "," -f 2`
spc_p1=`echo ${species} | cut -d "," -f 1`
summary_file_with_relative_path=${4}
summary_file_with_absolute_path=`readlink -f ${summary_file_with_relative_path}`

# Feedback.
echo "Input vcf file: ${gzvcf_with_absolute_path}."
echo "Input sample table file: ${sample_table_with_absolute_path}."
echo "Species string: ${species}."
echo

# Copy the vcf file to the temporary directory.
if [ -f ${gzvcf_with_absolute_path} ]
then
    cp ${gzvcf_with_absolute_path} ${SCRATCH}
else
    echo "ERROR: Could not find file ${gzvcf_with_absolute_path}!"
fi

# Copy r scripts to the temporary directory.
cp calculate_abba_baba.r ${SCRATCH}

# Move to the temporary directory.
cd ${SCRATCH}

# Make lists of species and samples.
zcat ${gzvcf_with_absolute_path} | head -n 20000 > head.vcf
for i in `cat head.vcf | grep CHROM | cut -f 10-`
do
    cat ${sample_table_with_absolute_path} | grep "^${i}"
done | cut -f 1,2 > all_samples.txt
cat all_samples.txt | grep -e ${spc_o} -e ${spc_p3} -e ${spc_p2} -e ${spc_p1} | sort > samples.txt

# Get the sample ids for the four species.
samples_o=`cat all_samples.txt | grep ${spc_o} | cut -f 1`
samples_p3=`cat all_samples.txt | grep ${spc_p3} | cut -f 1`
samples_p2=`cat all_samples.txt | grep ${spc_p2} | cut -f 1`
samples_p1=`cat all_samples.txt | grep ${spc_p1} | cut -f 1`

# Feedback.
str="Outgroup: ${spc_o} (samples: "
for i in ${samples_o}; do str="${str}${i}, "; done
str=`echo ${str} | rev | cut -c 2- | rev`
str="${str})."
echo ${str}
str="P3: ${spc_p3} (samples: "
for i in ${samples_p3}; do str="${str}${i}, "; done
str=`echo ${str} | rev | cut -c 2- | rev`
str="${str})."
echo ${str}
str="P2: ${spc_p2} (samples: "
for i in ${samples_p2}; do str="${str}${i}, "; done
str=`echo ${str} | rev | cut -c 2- | rev`
str="${str})."
echo ${str}
str="P1: ${spc_p1} (samples: "
for i in ${samples_p1}; do str="${str}${i}, "; done
str=`echo ${str} | rev | cut -c 2- | rev`
str="${str})."
echo ${str}
echo

# Make a subset of the vcf file.
echo -n "Subsetting the vcf file with bcftools..."
samples_all=`echo ${samples_o}; echo ${samples_p3}; echo ${samples_p2}; echo "${samples_p1}"`
samples_str=`echo ${samples_all} | sed 's/ /,/g'`
bcftools view -s `echo -n ${samples_str}` -a --min-ac=1 -O z -o t1.vcf.gz ${gzvcf}
bcftools view -e 'AC==0 || AC==AN || F_MISSING > 0.5' -O z -o t2.vcf.gz t1.vcf.gz
echo " done."

# Get simon martin's genomics_general code repository.
git clone https://github.com/simonhmartin/genomics_general.git
PYTHONPATH=${PYTHONPATH}:./genomics_general

# Convert the vcf to genotype format.
echo -n "Converting the vcf to geno format..."
python genomics_general/VCF_processing/parseVCF.py -i t2.vcf.gz | gzip > t2.geno.gz
echo " done."
echo

# Calculate allele frequencies.
echo -n "Calculating allele frequencies..."
python genomics_general/freq.py -g t2.geno.gz -p ${spc_p1} -p ${spc_p2} -p ${spc_p3} -p ${spc_o} --popsFile samples.txt --target derived 2> /dev/null | grep -v nan | gzip > allele_freqs.tsv.gz
echo " done."
echo

# Calculate abba-baba statistics across the whole genome.
echo -n "Calculating abba-baba statistics across the whole genome..."
Rscript calculate_abba_baba.r allele_freqs.tsv.gz abba_baba.summary.txt ${spc_p1} ${spc_p2} ${spc_p3} ${spc_o}
echo " done."

# Copy the abba-baba summary file back to the results directory.
cp abba_baba.summary.txt ${summary_file_with_absolute_path}
