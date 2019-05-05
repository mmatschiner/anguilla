# m_matschiner Mon Oct 22 12:00:20 CEST 2018

# Set the result table.
table=../res/tables/introgression.txt

# Analyze all abba-baba and f4 output files.
echo -e "p1\tp2\tp3\to\tn_sites\tn_bbaa\tn_abba\tn_baba\td\tfd\tf4\tp" > ${table}
for file in ../res/abbababa/*.txt
do
    # Get the file name without the path.
    file_base=`basename ${file}`

    # Get the species names.
    p1=`echo ${file_base} | cut -d "." -f 6 | cut -d "_" -f 1`
    p2=`echo ${file_base} | cut -d "." -f 6 | cut -d "_" -f 2`
    p3=`echo ${file_base} | cut -d "." -f 6 | cut -d "_" -f 3`
    o=`echo ${file_base} | cut -d "." -f 6 | cut -d "_" -f 4`

    # Get the numbers of sites
    n_sites=`cat ${file} | head -n 6 | tail -n 1 | cut -d ":" -f 2 | tr -d " "`
    n_bbaa=`cat ${file} | head -n 7 | tail -n 1 | cut -d ":" -f 2 | tr -d " "`
    n_bbaa_fmt=`printf '%1.1f' ${n_bbaa}`
    n_abba=`cat ${file} | head -n 8 | tail -n 1 | cut -d ":" -f 2 | tr -d " "`
    n_abba_fmt=`printf '%1.1f' ${n_abba}`
    n_baba=`cat ${file} | head -n 9 | tail -n 1 | cut -d ":" -f 2 | tr -d " "`
    n_baba_fmt=`printf '%1.1f' ${n_baba}`

    # Get the d and fd statistics.
    d=`cat ${file} | head -n 10 | tail -n 1 | cut -d ":" -f 2 | tr -d " "`
    d_fmt=`printf '%1.3f' ${d}`
    fd=`cat ${file} | head -n 11 | tail -n 1 | cut -d ":" -f 2 | tr -d " "`
    fd_fmt=`printf '%1.3f' ${fd}`

    # Get the f4 file name.
    f4_file=../res/f4/output/${file_base}

    # Get the f4 statistic and the p value based on simulations from the f4 file.
    f4=`cat ${f4_file} | grep "Observed f4:" | cut -d ":" -f 2`
    p=`cat ${f4_file} | grep "Proportion of simulated f4 values" | grep "than the observed:" | cut -d ":" -f 2`

    # Report the results.
    echo -e "${p1}\t${p2}\t${p3}\t${o}\t${n_sites}\t${n_bbaa_fmt}\t${n_abba_fmt}\t${n_baba_fmt}\t${d_fmt}\t${fd_fmt}\t${f4}\t${p}"

done | sort -n -r -k 9 >> ${table}