# m_matschiner Wed Jan 8 17:17:49 CET 2020

# Use picard-tools' SamToFastq function to generate a fastq from each bam file.
for bam in ../res/minimap/*.bam
do
    fastq1=${bam%.bam}.R1.fastq
    fastq2=${bam%.bam}.R2.fastq
    java -jar /projects/cees/bin/picard/2.7.1/picard.jar SamToFastq \
	I=${bam} \
	FASTQ=${fastq1} \
	SECOND_END_FASTQ=${fastq2} \
	QUIET=TRUE \
	VALIDATION_STRINGENCY=SILENT
done