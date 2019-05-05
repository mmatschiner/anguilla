# m_matschiner Mon Sep 3 09:54:41 CEST 2018

# Make the analysis directories.
for i in {1..5}
do
    mkdir -p ../res/snapp/all_species/transversions/replicates/r0${i}
    mkdir -p ../res/snapp/all_species/transitions/replicates/r0${i}
    mkdir -p ../res/snapp/all_species_t1/transversions/replicates/r0${i}
    mkdir -p ../res/snapp/all_species_t1/transitions/replicates/r0${i}
    mkdir -p ../res/snapp/all_species_t3/transversions/replicates/r0${i}
    mkdir -p ../res/snapp/all_species_t3/transitions/replicates/r0${i}
    mkdir -p ../res/snapp/red_species/transversions/replicates/r0${i}
    mkdir -p ../res/snapp/red_species/transitions/replicates/r0${i}
done

# Prepare replicate directories.
for i in ../res/snapp/all_species/transversions/replicates/r??
do
    if [ ! -f ${i}/eels_transversions.xml ]
    then
	cp ../data/xml/all_species/eels_transversions.xml ${i}
	cp run_snapp.slurm ${i}
    fi
done
for i in ../res/snapp/all_species/transitions/replicates/r??
do
    if [ ! -f ${i}/eels_transitions.xml ]
    then
	cp ../data/xml/all_species/eels_transitions.xml ${i}
	cp run_snapp.slurm ${i}
    fi
done

for i in ../res/snapp/all_species_t1/transversions/replicates/r??
do
    if [ ! -f ${i}/eels_transversions.xml ]
    then
        cp ../data/xml/all_species_t1/eels_transversions.xml ${i}
        cp run_snapp.slurm ${i}
    fi
done
for i in ../res/snapp/all_species_t1/transitions/replicates/r??
do
    if [ ! -f ${i}/eels_transitions.xml ]
    then
        cp ../data/xml/all_species_t1/eels_transitions.xml ${i}
        cp run_snapp.slurm ${i}
    fi
done

for i in ../res/snapp/all_species_t3/transversions/replicates/r??
do
    if [ ! -f ${i}/eels_transversions.xml ]
    then
        cp ../data/xml/all_species_t3/eels_transversions.xml ${i}
        cp run_snapp.slurm ${i}
    fi
done
for i in ../res/snapp/all_species_t3/transitions/replicates/r??
do
    if [ ! -f ${i}/eels_transitions.xml ]
    then
        cp ../data/xml/all_species_t3/eels_transitions.xml ${i}
        cp run_snapp.slurm ${i}
    fi
done

for i in ../res/snapp/red_species/transversions/replicates/r??
do
    if [ ! -f ${i}/eels_transversions.xml ]
    then
	cp ../data/xml/red_species/eels_transversions.xml ${i}
	cp run_snapp.slurm ${i}
    fi
done
for i in ../res/snapp/red_species/transitions/replicates/r??
do
    if [ ! -f ${i}/eels_transitions.xml ]
    then
	cp ../data/xml/red_species/eels_transitions.xml ${i}
	cp run_snapp.slurm ${i}
    fi
done

# Launch each replicate analysis.
xml=eels_transversions.xml
for i in ../res/snapp/all_species_t3/transversions/replicates/r??
do
    cd ${i}
    sbatch -o eels_transversions.out run_snapp.slurm ${xml}
    cd -
done
xml=eels_transitions.xml
for i in ../res/snapp/all_species_t3/transitions/replicates/r??
do
    cd ${i}
    sbatch -o eels_transitions.out run_snapp.slurm ${xml}
    cd -
done

xml=eels_transversions.xml
for i in ../res/snapp/all_species/transversions/replicates/r??
do
    cd ${i}
    sbatch -o eels_transversions.out run_snapp.slurm ${xml}
    cd -
done
xml=eels_transitions.xml
for i in ../res/snapp/all_species/transitions/replicates/r??
do
    cd ${i}
    sbatch -o eels_transitions.out run_snapp.slurm ${xml}
    cd -
done

xml=eels_transversions.xml
for i in ../res/snapp/all_species_t1/transversions/replicates/r??
do
    cd ${i}
    sbatch -o eels_transversions.out run_snapp.slurm ${xml}
    cd -
done
xml=eels_transitions.xml
for i in ../res/snapp/all_species_t1/transitions/replicates/r??
do
    cd ${i}
    sbatch -o eels_transitions.out run_snapp.slurm ${xml}
    cd -
done

xml=eels_transversions.xml
for i in ../res/snapp/red_species/transversions/replicates/r??
do
    cd ${i}
    sbatch -o eels_transversions.out run_snapp.slurm ${xml}
    cd -
done
xml=eels_transitions.xml
for i in ../res/snapp/red_species/transitions/replicates/r??
do
    cd ${i}
    sbatch -o eels_transitions.out run_snapp.slurm ${xml}
    cd -
done
