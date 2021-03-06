# m_matschiner Wed Jan 8 17:17:59 CET 2020

# Get the command line argument.
sample_id=${1}
reference=${2}

# Load the mitobim and mira modules.
module load mitobim/1.8
module load mira/4.0.2

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/mitobim

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/mitobim

# Make or empty a temporary directory.
rm -rf ~/tmp
mkdir ~/tmp

# Get the home directory.
home=`pwd`

# Copy the mitochondrial reference sequence to the temporary directory.
cp ${reference} ~/tmp/reference.fa

# Copy the fastq file for the first set of read mates to a new file in the temporary directory
# (following http://mira-assembler.sourceforge.net/docs/DefinitiveGuideToMIRA.html#sect_ref_misc_nw, not all data is used).
cp ../res/minimap/${sample_id}.R1.fastq ~/tmp/reads.fastq

# Move to the temporary directory.
cd ~/tmp

# Write a manifest file with settings for mira.
echo "#manifest file for basic mapping assembly with illumina data using MIRA 4" > manifest.conf
echo "" >> manifest.conf
echo "project = ${sample_id}" >> manifest.conf
echo "" >> manifest.conf
echo "job=genome,mapping,accurate" >> manifest.conf
echo "" >> manifest.conf
echo "parameters = -NW:mrnl=0 -NW:cac=warn -AS:nop=1 SOLEXA_SETTINGS -CO:msr=no" >> manifest.conf
echo "" >> manifest.conf
echo "readgroup" >> manifest.conf
echo "is_reference" >> manifest.conf
echo "data = reference.fa" >> manifest.conf
echo "strain = ${sample_id}" >> manifest.conf
echo "" >> manifest.conf
echo "readgroup = reads" >> manifest.conf
echo "data = reads.fastq" >> manifest.conf
echo "technology = solexa" >> manifest.conf
echo "strain = sample_${sample_id}" >> manifest.conf

# Run mira.
mira manifest.conf > ${sample_id}.log

# Run mitobim
/cluster/software/VERSIONS/mitobim-1.8/MITObim_1.8.pl \
    -start 1 \
    -end 10 \
    -sample sample_${sample_id} \
    -ref reference.fa \
    -readpool reads.fastq \
    -maf ${sample_id}_assembly/${sample_id}_d_results/${sample_id}_out.maf >> ${sample_id}.log

# Copy the fasta file of the last iteration to the output directory.
for i in iteration*
do
    cp -f ${i}/sample_${sample_id}-reference.fa_assembly/sample_${sample_id}-reference.fa_d_results/sample_${sample_id}-reference.fa_out_sample_${sample_id}.unpadded.fasta ${home}/../res/mitobim/${sample_id}.fasta
done

# Copy the log file to the log directory.
cp ${sample_id}.log ${home}/../log/mitobim

# Move back to the home directory.
cd ${home}

# Clean up.
rm -rf ~/tmp