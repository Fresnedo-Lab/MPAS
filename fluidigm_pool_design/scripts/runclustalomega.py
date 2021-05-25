#!/usr/bin/env python3

import sys
import os
from Bio.Align.Applications import ClustalOmegaCommandline

poolfiles = sys.argv


in_file = "../out/pools/pool1.fasta"
out_file = "../out/pools/clustalout/pool1_aligned.fasta"
clustalomega_cline = ClustalOmegaCommandline(infile=in_file, outfile=out_file, verbose=True, auto=True)
print(clustalomega_cline)
# clustalo -i unaligned.fasta -o aligned.fasta --auto -v

# run with this command:
clustalomega_cline()

