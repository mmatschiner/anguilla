# m_matschiner Thu Oct 18 09:17:39 CEST 2018

# Load the python3 module.
module load python3/3.5.0
module load beast2/2.5.0

# Combine log and trees files for the analyses of the eel species tree.
for taxa in all_species all_species_t1 all_species_t3 red_species
do
    for mode in transitions transversions
    do
	if [ ! -f ../res/snapp/${taxa}/${mode}/combined/eels_${mode}.log ]
	then
	    mkdir -p ../res/snapp/${taxa}/${mode}/combined
	    ls ../res/snapp/${taxa}/${mode}/replicates/r??/eels_${mode}.log > ../res/snapp/${taxa}/${mode}/combined/logs.txt
	    ls ../res/snapp/${taxa}/${mode}/replicates/r??/eels_${mode}.trees > ../res/snapp/${taxa}/${mode}/combined/trees.txt
	    python3 logcombiner.py -n 2000 -b 10 ../res/snapp/${taxa}/${mode}/combined/logs.txt ../res/snapp/${taxa}/${mode}/combined/eels_${mode}.log
	    python3 logcombiner.py -n 2000 -b 10 ../res/snapp/${taxa}/${mode}/combined/trees.txt ../res/snapp/${taxa}/${mode}/combined/eels_${mode}.trees
	    treeannotator -b 0 -heights mean ../res/snapp/${taxa}/${mode}/combined/eels_${mode}.trees ../res/snapp/${taxa}/${mode}/combined/eels_${mode}.tre
	fi
    done
done