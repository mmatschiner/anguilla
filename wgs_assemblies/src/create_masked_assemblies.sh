# m_matschiner Wed Jan 8 21:31:21 CET 2020

# Create a folder for the repeat libraries and the RepeatModeler run
repeat_lib_dir=../data/repeat_libraries
mkdir -p ${repeat_lib_dir}

# Make the log directory if it doesn't exist yet.
mkdir -p ../log/repeat_masking

# Mask the ang assembly.
out="../log/repeat_masking/ang.txt"
rm -f ${out}
sbatch -o ${out} run_repeatmodeler_masker.slurm ${repeat_lib_dir} ang ../data/subjects/angang.fasta

# Mask the jap assembly.
out="../log/repeat_masking/jap.txt"
rm -f ${out}
sbatch -o ${out} run_repeatmodeler_masker.slurm ${repeat_lib_dir} jap ../data/subjects/angjap.fasta

# Mask the mar, meg, and obs assemblies.
for species in mar meg obs
do
    out="../log/repeat_masking/${species}.txt"
    rm -f ${out}
    sbatch -o ${out} run_repeatmodeler_masker.slurm ${repeat_lib_dir} ${species} ../data/subjects/ang${species}.fasta
done
