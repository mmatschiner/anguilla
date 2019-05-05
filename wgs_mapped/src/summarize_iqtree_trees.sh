# m_matschiner Thu Apr 18 11:02:06 CEST 2019

# Set the summary file name.
summary_file=../res/sliding_window_phylogenies/summary.txt
echo -e "scaffold\tfrom\tto\ttree" > ${summary_file}

# Summarize the trees per scaffold
for tree_dir in ../res/sliding_window_phylogenies/trees/*
do
    echo "Summarizing trees in ${tree_dir}"
    scaffold=`basename ${tree_dir}`
    for tree in ${tree_dir}/*.tre
    do
	from=`basename ${tree%.tre} | cut -d "_" -f 2`
	to=`basename ${tree%.tre} | cut -d "_" -f 3`
	tree_string=`cat ${tree} | tr -d [0-9:.] | tr -d ";"`
	echo -e "${scaffold}\t${from}\t${to}\t${tree_string}" >> ${summary_file}
    done
done