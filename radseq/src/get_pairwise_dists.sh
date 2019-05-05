# m_matschiner Thu Mar 14 17:54:22 CET 2019

# Load modules.
module load ruby/2.1.5
module load python3/3.5.0

# Uncompress the compressed fasta directory if it is present.
if [ -f ../data/fasta/anguilla_aln2.tgz ]
then
	cd ../data/fasta
	tar -xzf anguilla_aln2.tgz
	cd -
fi

# Ensure that the uncompressed fasta directory is in place.
if [ ! -d ../data/fasta/anguilla_aln2 ]
then
	echo "Please download the file anguilla_aln2.tgz from the Dryad repository and place it in '../data/fasta', then restart this script."
	exit 0
fi

# Set file names.
fasta_dir=../data/fasta/anguilla_aln2
species_table=../data/tables/all_samples_with_mitochondrial_assignment.sorted.no_amb.txt
dists_table=../res/tables/pairwise_distances.txt
dists_per_species_table=../res/tables/pairwise_distances.species.txt

# Convert fasta files to nexus format.
mkdir tmp
for fasta in ${fasta_dir}/*.fasta
do
    align_id=`basename ${fasta%.fasta}`
    python3 convert.py ${fasta} tmp/${align_id}.nex -f nexus
done

# Concatenate nexus files.
ruby concatenate.rb -i tmp/*.nex -o tmp.concatenated.nex -f nexus

# Get pairwise distances.
# This may be killed when run on login nodes.
ruby get_pairwise_dists_from_nexus.rb -i tmp.concatenated.nex -o ${dists_table}

# Summarize the pairwise distances between species.
ruby summarize_pairwise_dists.rb ${dists_table} ${species_table} ${dists_per_species_table}