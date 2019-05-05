# m_matschiner Mon Apr 16 12:47:43 CEST 2018

# Define functions to calculate the numbers of abba and baba patterns.
bbaa = function(p1, p2, p3, p4) p1 * p2 * (1 - p3) * (1 - p4)
abba = function(p1, p2, p3, p4) (1 - p1) * p2 * p3 * (1 - p4)
baba = function(p1, p2, p3, p4) p1 * (1 - p2) * p3 * (1 - p4)
D.stat = function(dataframe) (sum(dataframe$ABBA) - sum(dataframe$BABA)) / (sum(dataframe$ABBA) + sum(dataframe$BABA))
fd.stat = function(p1, p2, p3, p4) {
    pd = pmax(p2, p3)
    (sum(abba(p1, p2, p3, p4)) - sum(baba(p1, p2, p3, p4))) / (sum(abba(p1, pd, pd, p4)) - sum(baba(p1, pd, pd, p4)))
}

# Get the command-line arguments.
args <- commandArgs(trailingOnly = TRUE)
allele_freqs_file_name <- args[1]
output_file_name <- args[2]
spc_p1 <- args[3]
spc_p2 <- args[4]
spc_p3 <- args[5]
spc_o <- args[6]

# Read the allele-frequencies table.
freq_table = read.table(allele_freqs_file_name, header=T, as.is=T)

# Open the output file.
output_file <- file(output_file_name, "w")

# Output.
write(paste("Species 1: ", spc_p1, sep=""), output_file, append=T)
write(paste("Species 2: ", spc_p2, sep=""), output_file, append=T)
write(paste("Species 3: ", spc_p3, sep=""), output_file, append=T)
write(paste("Species O: ", spc_o, sep=""), output_file, append=T)
write("", output_file, append=T)
write(paste("Number of sites: ", nrow(freq_table), sep=""), output_file, append=T)

# Get the allele frequencies.
p1 = freq_table[,spc_p1]
p2 = freq_table[,spc_p2]
p3 = freq_table[,spc_p3]
p4 = freq_table[,spc_o]

# Calculate the number of abba and baba patterns.
BBAA = bbaa(p1, p2, p3, p4)
ABBA = abba(p1,	p2, p3,	p4)
BABA = baba(p1,	p2, p3,	p4)

# Calculate the d statistic.
ABBA_BABA_df = as.data.frame(cbind(ABBA,BABA))
D = D.stat(ABBA_BABA_df)

# Calculate Simon Martin's fd statistic.
fd = fd.stat(p1, p2, p3, p4)

# Output.
write(paste("Number of BBAA sites: ", sum(BBAA), sep=""), output_file, append=T)
write(paste("Number of ABBA sites: ", sum(ABBA), sep=""), output_file, append=T)
write(paste("Number of BABA sites: ", sum(BABA), sep=""), output_file, append=T)
write(paste("D statistic: ", D, sep=""), output_file, append=T)
write(paste("fd statistic: ", fd, sep=""), output_file, append=T)
if( sum(ABBA) > sum(BBAA)){
    cat(paste("\nWARNING: The number of ABBA sites (", sum(ABBA) , ") is greater than the number of BBAA sites (", sum(BBAA) , "), indicating that ", spc_p2, " and ", spc_p3, " are more closely related than ", spc_p1, " and ", spc_p2, ". You should swap ", spc_p1, " and ", spc_p3, " to get the correct D-statistic.\n\n", sep=""))
}

# Close the output file.
close(output_file)

# Feedback.
cat(paste("\nWrote results to file ", output_file_name, ".\n\n", sep=""))
