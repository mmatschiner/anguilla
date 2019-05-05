# m_matschiner Wed Apr 17 16:22:22 CEST 2019

# Load modules.
module load python3/3.5.0

# Make the result directory.
window_dir=../res/sliding_window_phylogenies/alignments/windows
mkdir -p ${window_dir}

# Set the window size.
window_size=20000
increment=10000

# Cut alignments into windows.
for fasta in ../res/sliding_window_phylogenies/alignments/full/*.fasta
do
    cat ${fasta} | sed 's/..\/data\/fastq\/OBS_L001.sorted.dedup.realn.rgadd.bam.d15D140.fq/obs/g' > tmp.1.fasta
    cat tmp.1.fasta | sed 's/..\/data\/fastq\/MEG_L001.sorted.dedup.realn.rgadd.bam.d15D140.fq/mar/g' > tmp.2.fasta # this corrects the mar/meg ids.
    rm -f tmp.1.fasta
    cat tmp.2.fasta | sed 's/..\/data\/fastq\/MAR_L001.sorted.dedup.realn.rgadd.bam.d15D140.fq/meg/g' > tmp.3.fasta # this corrects the mar/meg ids.
    rm -f tmp.2.fasta
    cat tmp.3.fasta | sed 's/..\/..\/introgression_analyses\/data\/reference\/angang.fasta/ang/g' > tmp.4.fasta
    rm -f tmp.3.fasta
    length=`head -n 2 tmp.4.fasta | wc -m`
    fasta_base=`basename ${fasta}`
    mkdir -p ${window_dir}/${fasta_base%.fasta}
    for from in `seq 1 ${increment} ${length}`
    do
	to=$((${from} + ${window_size} - 1))
	out_fasta=${window_dir}/${fasta_base%.fasta}/${fasta_base%.fasta}_${from}_${to}.fasta
	if [ ! -f ${out_fasta} ]
	then
	    python3 trim_fasta.py tmp.4.fasta ${out_fasta} -sp ${from} -wl ${window_size}
	    echo "Wrote file ${out_fasta}."
	fi
    done
    rm -f tmp.4.fasta
done