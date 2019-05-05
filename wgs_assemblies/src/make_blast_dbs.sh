# m_matschiner Sat Apr 1 09:06:15 CEST 2017

# Load the blast module.
module load blast+/2.2.29

# Make a blast database for each fasta subject.
for i in ../data/subjects/*.fasta
do
    if [ ! -f ${i}*.nhr ]
    then
	makeblastdb -in ${i} -dbtype nucl
    fi
done