#!/bin/bash

# name: runprimalscheme2.sh
# author: Daniel R. Williams
# date: 30 May 2021

# Description:
# This script
#
# input: directory to search for fasta files, other parameters.
# output: directory with tsv, bed, and json files produced from primalscheme.
#
# example command:  Rscript runprimalscheme2.sh -d <in_dir> -o <out_dir>

# These are determined by PCR requirements. FLuidigm has strict parameters. Illumina MiSeq is less picky.
AMPMIN=180
AMPMAX=500


while getopts d:o:a:b:p:q:r flag
do
    case "${flag}" in
        d) in_dir=${OPTARG};;
        o) out_dir=${OPTARG};;
        a) ampmin=${OPTARG};;
        b) ampmax=${OPTARG};;
        p) minoverlap=${OPTARG};;
        q) maxoverlap=${OPTARG};;
        r) incrementoverlap=${OPTARG};;
    esac
done


# This fastas named in the list with specified overlaps
LIST=($(ls fastas | awk 'BEGIN {FS = "."}{ORS = " "} {print $1}'))
OVERLAPS=(40 45 50 55 60 65 70 75 80 85 90)
for OVERLAP in ${OVERLAPS[@]}; do mkdir overlap_$OVERLAP; for GENE in ${LIST[@]}; do primalscheme multiplex -a $AMPMIN -a $AMPMAX -n $GENE -t $OVERLAP -o overlap_$OVERLAP/$GENE -f fastas/$GENE.fasta; done; done

exit

