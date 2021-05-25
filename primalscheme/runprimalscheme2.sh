#!/bin/bash

# These are determined by PCR requirements. FLuidigm has strict parameters. Illumina MiSeq is less picky.
AMPMIN=180
AMPMAX=500

# This fastas named in the list with specified overlaps
LIST=($(ls fastas | awk 'BEGIN {FS = "."}{ORS = " "} {print $1}'))
OVERLAPS=(40 45 50 55 60 65 70 75 80 85 90)
for OVERLAP in ${OVERLAPS[@]}; do mkdir overlap_$OVERLAP; for GENE in ${LIST[@]}; do primalscheme multiplex -a $AMPMIN -a $AMPMAX -n $GENE -t $OVERLAP -o overlap_$OVERLAP/$GENE -f fastas/$GENE.fasta; done; done

exit

