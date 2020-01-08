# m_matschiner Wed Dec 25 14:27:00 CET 2019

# Load the blast module.
module load blast+/2.2.29

# Make a blast database for each fasta subject.
for i in ../res/mitobim/*.fasta
do
    if [ ! -f ${i}*.nhr ]
    then
	makeblastdb -in ${i} -dbtype nucl
    fi
done