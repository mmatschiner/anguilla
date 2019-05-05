# m_matschiner Sun Nov 11 23:05:28 CET 2018

# Make the result directory.
mkdir -p ../res/alignments/orthologs/08

# Copy alignments for genes used in musilova et al. 2019.
while read line
do
    if [ -f ../res/alignments/orthologs/07/${line}.fasta ]
    then
	cp ../res/alignments/orthologs/07/${line}.fasta ../res/alignments/orthologs/08
    fi
done < ../data/tables/musilova_et_al_genes.txt