# m_matschiner Thu Aug 30 15:54:27 CEST 2018

# Load the bcftools and vcftools modules.
module load bcftools/1.6
module load vcftools/0.1.14.zlib.1.2.8

# Ensure that the vcf file is in place.
if [ ! -f ../data/vcf/anguilla_var2.vcf.gz ]
then
    echo "Please download the file anguilla_var2.vcf.gz from the Dryad repository and place it in '../data/vcf', then restart this script."
fi

# Thin the vcf with vcftools.
vcftools --gzvcf ../data/vcf/anguilla_var2.vcf.gz --thin 100 --recode --recode-INFO-all --out ../data/vcf/anguilla_var2.thin
cat ../data/vcf/anguilla_var2.thin.recode.vcf | bgzip > ../data/vcf/anguilla_var2.thin.vcf.gz
rm ../data/vcf/anguilla_var2.thin.recode.vcf

# Index the vcf file.
bcftools index ../data/vcf/anguilla_var2.thin.vcf.gz
