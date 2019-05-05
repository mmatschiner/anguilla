# m_matschiner Sun Sep 2 19:05:56 CEST 2018

# Make a directory for the xml preparation for the snapp analysis.
mkdir -p ../data/xml/all_species
mkdir -p ../data/xml/all_species_t1
mkdir -p ../data/xml/all_species_t3
mkdir -p ../data/xml/red_species

# Load the bcftools and ruby modules.
module load bcftools/1.6
module load ruby/2.1.5

# Set the input vcf file.
gzvcf_in=../data/vcf/anguilla_var2.thin.vcf.gz

# Set the output vcf file.
vcf_out_all_species=../data/vcf/anguilla_var2.thin.snapp.all_species.vcf.gz
vcf_out_red_species=../data/vcf/anguilla_var2.thin.snapp.red_species.vcf.gz

# Set table names.
core_samples_table=../data/tables/core_samples.txt
all_samples_table=../data/tables/all_samples_with_mitochondrial_assignment.no_amb.txt
snapp_samples_table_all_species=../data/xml/all_species/spc.txt
snapp_samples_table_all_species_t1=../data/xml/all_species_t1/spc.txt
snapp_samples_table_all_species_t3=../data/xml/all_species_t3/spc.txt
snapp_samples_table_red_species=../data/xml/red_species/spc.txt
starting_tree_all_species_t1=../data/trees/starting_all_species_t1.tre
starting_tree_all_species_t2=../data/trees/starting_all_species_t2.tre
starting_tree_all_species_t3=../data/trees/starting_all_species_t3.tre
starting_tree_red_species=../data/trees/starting_red_species.tre
missingness_table=../data/tables/anguilla_var2.allele_freqs.txt

# Get a list of samples in the vcf.
bcftools query -l ${gzvcf_in} > tmp.samples_in_vcf.txt

# Reduce the core and all samples tables to only those that are in the vcf.
cat ${core_samples_table} | grep -f tmp.samples_in_vcf.txt > tmp.core_samples_in_vcf.txt
cat ${all_samples_table} | grep -f tmp.samples_in_vcf.txt > tmp.all_samples_in_vcf.txt

# Make tables with names of samples from the four populations.
cat tmp.core_samples_in_vcf.txt | grep core_mar | cut -f 1 > tmp.core_samples_in_vcf_mar.txt
cat tmp.core_samples_in_vcf.txt | grep core_meg | cut -f 1 > tmp.core_samples_in_vcf_meg.txt
cat tmp.core_samples_in_vcf.txt | grep core_obs | cut -f 1 > tmp.core_samples_in_vcf_obs.txt
cat tmp.core_samples_in_vcf.txt | grep core_luz | cut -f 1 > tmp.core_samples_in_vcf_luz.txt

# Make a list of the ten most most complete samples per population
cat ${missingness_table} | grep -f tmp.core_samples_in_vcf_mar.txt | sort -n -k5 | head -n 5 | cut -f 1 > tmp.samples_for_snapp_mar.txt
cat ${missingness_table} | grep -f tmp.core_samples_in_vcf_meg.txt | sort -n -k5 | head -n 5 | cut -f 1 > tmp.samples_for_snapp_meg.txt
cat ${missingness_table} | grep -f tmp.core_samples_in_vcf_obs.txt | sort -n -k5 | head -n 5 | cut -f 1 > tmp.samples_for_snapp_obs.txt
cat ${missingness_table} | grep -f tmp.core_samples_in_vcf_luz.txt | sort -n -k5 | head -n 5 | cut -f 1 > tmp.samples_for_snapp_luz.txt

# Make lists of samples of other populations.
cat tmp.all_samples_in_vcf.txt | grep bic | cut -f 1 > tmp.samples_for_snapp_bic.txt
cat tmp.all_samples_in_vcf.txt | grep int | cut -f 1 > tmp.samples_for_snapp_int.txt
cat tmp.all_samples_in_vcf.txt | grep mos | cut -f 1 > tmp.samples_for_snapp_mos.txt

# Make lists of all samples that will be used in the snapp analyses.
cat tmp.samples_for_snapp_{mar,meg,obs,luz,bic,int,mos}.txt > tmp.samples_for_snapp.all_species.txt
cat tmp.samples_for_snapp_{mar,meg,obs,bic,mos}.txt > tmp.samples_for_snapp.red_species.txt

# Make a vcf file for including only the most complete samples.
bcftools view -S tmp.samples_for_snapp.all_species.txt -a --min-ac=1 -o ${vcf_out_all_species} ${gzvcf_in}
bcftools view -S tmp.samples_for_snapp.red_species.txt -a --min-ac=1 -o ${vcf_out_red_species} ${gzvcf_in}

# Make a species table for snapp_prep.rb.
echo -e "species\tspecimen" > ${snapp_samples_table_all_species}
echo -e "species\tspecimen" > ${snapp_samples_table_red_species}
while read line
do
    echo -e "mar\t${line}" >> ${snapp_samples_table_all_species}
    echo -e "mar\t${line}" >> ${snapp_samples_table_red_species}
done < tmp.samples_for_snapp_mar.txt
while read line
do
    echo -e "meg\t${line}" >> ${snapp_samples_table_all_species}
    echo -e "meg\t${line}" >> ${snapp_samples_table_red_species}
done < tmp.samples_for_snapp_meg.txt
while read line
do
    echo -e "obs\t${line}" >> ${snapp_samples_table_all_species}
    echo -e "obs\t${line}" >> ${snapp_samples_table_red_species}
done < tmp.samples_for_snapp_obs.txt
while read line
do
    echo -e "luz\t${line}" >> ${snapp_samples_table_all_species}
done < tmp.samples_for_snapp_luz.txt
while read line
do
    echo -e "bic\t${line}" >> ${snapp_samples_table_all_species}
    echo -e "bic\t${line}" >> ${snapp_samples_table_red_species}
done < tmp.samples_for_snapp_bic.txt
while read line
do
    echo -e "int\t${line}" >> ${snapp_samples_table_all_species}
done < tmp.samples_for_snapp_int.txt
while read line
do
    echo -e "mos\t${line}" >> ${snapp_samples_table_all_species}
    echo -e "mos\t${line}" >> ${snapp_samples_table_red_species}
done < tmp.samples_for_snapp_mos.txt

# Download the snapp_prep.rb script.
if [ ! -f snapp_prep.rb ]
then
    wget https://raw.githubusercontent.com/mmatschiner/snapp_prep/master/snapp_prep.rb
fi

# Make fake constraint file.
echo -e "lognormal(0,13.76,0.1)\tcrown\tmar,meg,obs,luz,bic,int,mos" > tmp.constraint.all_species.txt
echo -e "lognormal(0,13.76,0.1)\tcrown\tmar,meg,obs,bic,mos" > tmp.constraint.red_species.txt

# Make input files for snapp with snapp_prep.rb.
xml=../data/xml/all_species/eels_transversions.xml
ruby snapp_prep.rb -v ${vcf_out_all_species} -t ${snapp_samples_table_all_species} -o eels_transversions -x ${xml} -c tmp.constraint.all_species.txt -s ${starting_tree_all_species_t2} -r -l 25000 -m 5000

xml=../data/xml/all_species/eels_transitions.xml
ruby snapp_prep.rb -v ${vcf_out_all_species} -t ${snapp_samples_table_all_species} -o eels_transitions -x ${xml} -c tmp.constraint.all_species.txt -s ${starting_tree_all_species_t2} -i -l 25000 -m 5000

xml=../data/xml/all_species_t1/eels_transversions.xml
ruby snapp_prep.rb -v ${vcf_out_all_species} -t ${snapp_samples_table_all_species} -o eels_transversions -x ${xml} -c tmp.constraint.all_species.txt -s ${starting_tree_all_species_t1} -w 0 -r -l 25000 -m 5000

xml=../data/xml/all_species_t1/eels_transitions.xml
ruby snapp_prep.rb -v ${vcf_out_all_species} -t ${snapp_samples_table_all_species} -o eels_transitions -x ${xml} -c tmp.constraint.all_species.txt -s ${starting_tree_all_species_t1} -w 0 -i -l 25000 -m 5000

xml=../data/xml/all_species_t3/eels_transversions.xml
ruby snapp_prep.rb -v ${vcf_out_all_species} -t ${snapp_samples_table_all_species} -o eels_transversions -x ${xml} -c tmp.constraint.all_species.txt -s ${starting_tree_all_species_t3} -w 0 -r -l 25000 -m 5000

xml=../data/xml/all_species_t3/eels_transitions.xml
ruby snapp_prep.rb -v ${vcf_out_all_species} -t ${snapp_samples_table_all_species} -o eels_transitions -x ${xml} -c tmp.constraint.all_species.txt -s ${starting_tree_all_species_t3} -w 0 -i -l 25000 -m 5000


xml=../data/xml/red_species/eels_transversions.xml
ruby snapp_prep.rb -v ${vcf_out_red_species} -t ${snapp_samples_table_red_species} -o eels_transversions -x ${xml} -c tmp.constraint.red_species.txt -s ${starting_tree_red_species} -r -l 25000 -m 5000

xml=../data/xml/red_species/eels_transitions.xml
ruby snapp_prep.rb -v ${vcf_out_red_species} -t ${snapp_samples_table_red_species} -o eels_transitions -x ${xml} -c tmp.constraint.red_species.txt -s ${starting_tree_red_species} -i -l 25000 -m 5000

# Copy sample lists.
cp ${snapp_samples_table_all_species} ${snapp_samples_table_all_species_t1}
cp ${snapp_samples_table_all_species} ${snapp_samples_table_all_species_t3}

# Clean up.
rm tmp.samples_*
rm tmp.core_samples_*
rm tmp.all_samples_*
rm tmp.constraint.???_species.txt