#!/usr/local/bin/python3

# Michael Matschiner, 2015-02-23
# michaelmatschiner@mac.com

# Import libraries and make sure we're on python 3.
import sys
if sys.version_info[0] < 3:
    print('Python 3 is needed to run this script!')
    sys.exit(0)
import argparse, textwrap, random, os, re
from subprocess import call
from Bio import AlignIO

# Parse the command line arguments.
parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description=textwrap.dedent('''\
      %(prog)s
    -----------------------------------------
      Converter to fasta format.
      If a start position and a window length are specified,
      the alignment is trimmed accordingly.
    '''))
parser.add_argument(
    '-v', '--version',
    action='version',
    version='%(prog)s 0.9'
    )
parser.add_argument(
    '-sp', '--startposition',
    nargs=1,
    type=int,
    default=[1],
    dest='startposition',
    help="Start position for trimmed alignment"
    )
parser.add_argument(
    '-wl', '--windowlength',
    nargs=1,
    type=int,
    dest='windowlength',
    help="Length of trimmed alignment window (in bp)"
    )
parser.add_argument(
    'infile',
    nargs='?',
    type=argparse.FileType('r'),
    default='-',
    help='The input file name.'
    )
parser.add_argument(
    'outfile',
    nargs='?',
    type=argparse.FileType('w'),
    default=sys.stdout,
    help='The output file name.'
    )
args = parser.parse_args()
startposition = args.startposition[0]
windowlength = args.windowlength[0]
infile = args.infile
outfile = args.outfile

if infile.isatty():
    print('No input file specified, and no input piped through stdin!')
    sys.exit(0)
instring = infile.read()
inlines = instring.split('\n')

record_ids = []
record_seqs = []
for inline in inlines:
    if inline.strip() != '':
        if inline[0] == '>':
            record_ids.append(inline[1:])
            record_seqs.append('')
        else:
            record_seqs[-1] += inline.strip()

# Make sure all record_seqs are of the same length.
for record_seq in record_seqs[1:]:
    if len(record_seq) != len(record_seqs[0]):
        print('WARNING: Not all sequences are of the same length!')
# Trim sequences according to startposition and windowlength.
trimmmed_record_seqs = []
if windowlength == None:
    for record_seq in record_seqs:
        trimmmed_record_seqs.append(record_seq[startposition-1:])
else:
    for record_seq in record_seqs:
        trimmmed_record_seqs.append(record_seq[startposition-1:startposition+windowlength-1])
record_seqs = trimmmed_record_seqs
# Get the maximum length of record ids.
max_record_id_length = 0
for record_id in record_ids:
    if len(record_id) > max_record_id_length:
        max_record_id_length = len(record_id)
# Test whether all sequences are uninformative.
# Write the fasta string.
fasta_string = ''
for x in range(len(record_ids)):
    fasta_string += '>' + record_ids[x].ljust(max_record_id_length + 2) + '\n' + record_seqs[x] + '\n'

# Write the output string to file or STDOUT.
outfile.write(fasta_string)
