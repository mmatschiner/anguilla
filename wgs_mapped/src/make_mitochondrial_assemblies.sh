# m_matschiner Wed Jan 8 17:17:56 CET 2020

# Make mitochondrial assemblies with mira and mitobim.
for bam in ../res/minimap/*.bam
do
    sample_id=`basename ${bam%.bam}`
    if [ ${sample_id} == mar ]
    then
	reference=../data/queries/angmar_NC_006540.fasta
    elif [ ${sample_id} == meg ]
    then
	reference=../data/queries/angmeg_NC_006541.fasta
    else
	echo "ERROR: Unexpected sample id: ${sample_id}!"
	exit 1
    fi
    if [ ! -f ../res/mitobim/${sample_id}.fasta ]
    then
	bash make_mitochondrial_assembly.sh ${sample_id} ${reference}
    fi
done