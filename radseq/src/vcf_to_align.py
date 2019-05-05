# Michael Matschiner, 2014-07-24
# michaelmatschiner@mac.com

# Import libraries and make sure we're on python 3.
import sys
if sys.version_info[0] < 3:
    print('Python 3 is needed to run this script!')
    sys.exit(0)
import argparse, textwrap, vcf
from Bio.Alphabet import generic_dna
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.Align import MultipleSeqAlignment
from Bio import AlignIO

# Parse the command line arguments.
parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description=textwrap.dedent('''\
      %(prog)s
    -----------------------------------------
      Convert a VCF file to an alignment.
    '''))
parser.add_argument('-v', '--version', action='version', version='%(prog)s 1.0')
parser.add_argument('-f', '--format', nargs=1, type=str, default=['nexus'], metavar='NAME', help='The format of the output alignment.')
parser.add_argument('infile', nargs='?', type=argparse.FileType('r'), default='-', help='The input file name.')
parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'), default=sys.stdout, help='The output file name.')
args = parser.parse_args()
format = args.format[0]
infile = args.infile
outfile = args.outfile
if infile.isatty():
    print('No input file specified, and no input piped through stdin!')
    sys.exit(0)

# Read the infile.
vcf_data = vcf.Reader(infile)
sample_ids = vcf_data.samples
records = []
first_record = None
for record in vcf_data:
    if type(first_record) == type(None):
        first_record = record
    record_genotypes = []
    if len(record.samples) != len(first_record.samples):
        print("Record lengths differ for record " + str(record) + "!", file=sys.stderr)
        sys.exit(1)
    for sample in record:
        if sample.gt_bases == "A/A":
            record_genotypes.append("A")
        elif sample.gt_bases == "A/C":
            record_genotypes.append("M")
        elif sample.gt_bases == "A/G":
            record_genotypes.append("R")
        elif sample.gt_bases == "A/T":
            record_genotypes.append("W")
        elif sample.gt_bases == "C/A":
            record_genotypes.append("M")
        elif sample.gt_bases == "C/C":
            record_genotypes.append("C")
        elif sample.gt_bases == "C/G":
            record_genotypes.append("S")
        elif sample.gt_bases == "C/T":
            record_genotypes.append("Y")
        elif sample.gt_bases == "G/A":
            record_genotypes.append("R")
        elif sample.gt_bases == "G/C":
            record_genotypes.append("S")
        elif sample.gt_bases == "G/G":
            record_genotypes.append("G")
        elif sample.gt_bases == "G/T":
            record_genotypes.append("K")
        elif sample.gt_bases == "T/A":
            record_genotypes.append("W")
        elif sample.gt_bases == "T/C":
            record_genotypes.append("Y")
        elif sample.gt_bases == "T/G":
            record_genotypes.append("K")
        elif sample.gt_bases == "T/T":
            record_genotypes.append("T")
        elif sample.gt_bases == None:
            record_genotypes.append("N")
        else:
            print("Unexpected genotype of sample" + str(sample) + ": " + str(sample.gt_bases), file=sys.stderr)
            sys.exit(1)
    records.append(record_genotypes)

# Test whether all records are of the same length.
for y in range(1,len(records)):
    if len(records[y]) != len(records[0]):
        print("The length of record " + str(y) + " (" + str(len(records[y])) + ") differs from that of record 0 (" + str(len(records[0])) + ")!" , file=sys.stderr)
        sys.exit(1)

# Convert to multiple sequence alignment.
seqs = []
for x in range(0,len(records[0])):
    seq = []
    for y in range(0,len(records)):
        this_record = records[y]
        this_position_of_this_record = this_record[x]
        seq.append(this_position_of_this_record)
    seqs.append(SeqRecord(Seq("".join(seq),generic_dna),id=sample_ids[x].replace('-','_')))
align = MultipleSeqAlignment(seqs)

# Write alignment.
AlignIO.write(align, outfile, format)
