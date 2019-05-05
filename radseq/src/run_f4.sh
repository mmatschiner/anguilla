# m_matschiner Wed Oct 24 16:18:04 CEST 2018

# Make the result directory.
mkdir -p ../res/f4/output

# Make the log directory.
mkdir -p ../log/f4

# Download the f4 script.
if [ ! -f f4.py ]
then
    wget --no-cache https://raw.githubusercontent.com/mmatschiner/F4/master/f4.py
fi

# Run f4 for all combinations of four species.
for file in ../res/f4/input/*.txt
do
    id=`basename ${file%.txt}`
    res=../res/f4/output/${id}.txt
    out=../log/f4/${id}.out
    log=../log/f4/${id}.log
    if [ ! -f ${res} ]
    then
	rm -f ${out}
	sbatch -o ${out} run_f4.slurm ${file} ${res} ${log}
    fi
done