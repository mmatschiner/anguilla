# m_matschiner Thu Sep 20 23:40:43 CEST 2018

# Load the ruby module.
module load ruby/2.1.5

# Ensure that the anguilla reference is in place.
if [ ! -f ../data/reference/ang.double_pilon.fasta ]
then
	echo "Please download file Anguilla_anguilla_assembly_racon_and_double_pilon_corrected.fasta from https://surfdrive.surf.nl/files/index.php/s/Gqh99whhDY0JetJ?path=%2Fracon_double_pilon_correction, name it 'ang.double_pilon.fasta', place it in '../data/reference', then restart this script."
	exit 0
fi

# Set the old and new ref file names.
ref=../data/reference/ang.double_pilon.fasta
new_ref=../data/reference/angang.fasta

# Run a ruby script to simplify the reference sequence ids.
ruby simplify_ref.rb ${ref} ${new_ref}