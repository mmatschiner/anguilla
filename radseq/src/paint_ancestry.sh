# m_matschiner Fri Aug 31 16:01:06 CEST 2018

# Load the ruby and bcftools modules.
module load ruby/2.1.5
module load bcftools/1.6

# Make the output directory.
mkdir -p ../res/ancestry_painting

# Set the name of the vcf file.
gzvcf=../data/vcf/anguilla_var2.thin.vcf.gz

# Set the name of the sample table.
table=../data/tables/core_samples.txt

# Download two ruby scripts for ancestry painting from github 
if [ ! -f get_fixed_site_gts.rb ]
then
    wget https://raw.githubusercontent.com/mmatschiner/tutorials/master/analysis_of_introgression_with_snp_data/src/get_fixed_site_gts.rb
fi
if [ ! -f plot_fixed_site_gts.rb ]
then
    wget https://raw.githubusercontent.com/mmatschiner/tutorials/master/analysis_of_introgression_with_snp_data/src/plot_fixed_site_gts.rb
fi

# Uncompress the vcf file.
bgzip -d -c ${gzvcf} > tmp.vcf

# Define a list of mar individuals according to sheet sw1 pdh-ad in file SW morphological analysis.xlsx (excl. NCA16084_L3I2, BOU15024_L4I3, SAW16001_L1I2 due to intermediate positions in morphology pca and BOU15029_L4I3, NCA16003_L3I2, VAG12022_L1I1, VAG12030_L1I1, VAG12059_L2I2 due to low completeness).
mar_string=`cat ${table} | grep core_mar | cut -f 1 | tr "\n" ","`
mar_string=${mar_string%,}

# Define a list of meg individuals according to sheet sw1 pdh-ad in file SW morphological analysis.xlsx (excl. VAG13075_L3I3 due to intermediate position in morphology pca).
meg_string=`cat ${table} | grep core_meg | cut -f 1 | tr "\n" ","`
meg_string=${meg_string%,}

# Define a list of obs individuals according to sheet sw1 pdh-ad in file SW morphological analysis.xlsx (excl. SAW16043_L3I1, SAW16044_L3I1 due to low completeness).
obs_string=`cat ${table} | grep core_obs | cut -f 1 | tr "\n" ","`
obs_string=${obs_string%,}

# Define a list of luz individuals according to the results of the genomic pca analysis.
luz_string=`cat ${table} | grep core_luz | cut -f 1 | tr "\n" ","`
luz_string=${luz_string%,}

# Define a list of int individuals according to the results of the genomic pca analysis.
int_string=`cat ${table} | grep core_int | cut -f 1 | tr "\n" ","`
int_string=${int_string%,}

# Define a list of putative mar-meg hybrid individuals according to sheet sw1 pdh-ad in file SW morphological analysis.xlsx (including BOU15024_L4I3 due to intermediate position in morphology pca, and SAA16011_L2I3, SAA16012_L2I3, SAA16013_L2I3, SAA16024_L2I3, SAA16027_L4I3, SAW17B27_L4I2, SAW17B49_L4I2, VAG12037_L2I2, VAG12053_L2I2, VAG13087_L3I3 due to intermediate position in genetic pca).
marmeg_string="BOU15024_L4I3,BOU15031_L4I3,SAA16011_L2I3,SAA16012_L2I3,SAA16013_L2I3,SAA16024_L2I3,SAA16027_L4I3,SAW17B27_L4I2,SAW17B49_L4I2,VAG12012_L1I1,VAG12018_L1I1,VAG12019_L1I1,VAG12024_L2I2,VAG12029_L1I1,VAG12037_L2I2,VAG12044_L2I2,VAG12053_L2I2,VAG12055_L3I3,VAG13071_L3I3,VAG13078_L2I1,VAG13087_L3I3"

# Define a list of putative mar-obs hybrid individuals according to sheet sw1 pdh-ad in file SW morphological analysis.xlsx (including VAG13077_L3I3 due to intermediate position in genetic pca).
marobs_string="VAG12040_L2I2,VAG12045_L2I1,VAG13077_L3I3"

# Define a list of putative meg-obs hybrid individuals according to sheet sw1 pdh-ad in file SW morphological analysis.xlsx.
megobs_string="VAG12049_L3I3"

# Define a list of putative mar-int hybrid individuals according to the results of the genetic pca.
marint_string="BOU15017_L1I4"

# Run the first ruby script for the three comparisons.
ruby get_fixed_site_gts.rb tmp.vcf ../res/ancestry_painting/fixed_sites.marmeg.txt ${mar_string} ${marmeg_string} ${meg_string} 0.8 1
ruby get_fixed_site_gts.rb tmp.vcf ../res/ancestry_painting/fixed_sites.marobs.txt ${mar_string} ${marobs_string} ${obs_string} 0.8 1
ruby get_fixed_site_gts.rb tmp.vcf ../res/ancestry_painting/fixed_sites.megobs.txt ${meg_string} ${megobs_string} ${obs_string} 0.8 1
ruby get_fixed_site_gts.rb tmp.vcf ../res/ancestry_painting/fixed_sites.marint.txt ${mar_string} ${marint_string} ${int_string} 0.8 1 

# Clean up.
rm -f tmp.vcf

# Run the second ruby script for the three comparisons.
ruby plot_fixed_site_gts.rb ../res/ancestry_painting/fixed_sites.marmeg.txt ../res/ancestry_painting/fixed_sites.marmeg.svg 0.8 100 > ../res/ancestry_painting/fixed_sites.marmeg.log
ruby plot_fixed_site_gts.rb ../res/ancestry_painting/fixed_sites.marobs.txt ../res/ancestry_painting/fixed_sites.marobs.svg 0.8 100 > ../res/ancestry_painting/fixed_sites.marobs.log
ruby plot_fixed_site_gts.rb ../res/ancestry_painting/fixed_sites.megobs.txt ../res/ancestry_painting/fixed_sites.megobs.svg 0.8 100 > ../res/ancestry_painting/fixed_sites.megobs.log
ruby plot_fixed_site_gts.rb ../res/ancestry_painting/fixed_sites.marint.txt ../res/ancestry_painting/fixed_sites.marint.svg 0.8 100 > ../res/ancestry_painting/fixed_sites.marint.log