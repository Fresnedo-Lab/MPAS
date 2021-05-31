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
# example command:  shell runprimalscheme2.sh -d <in_dir> -o <out_dir>

# These are determined by PCR requirements. FLuidigm has strict parameters. Illumina MiSeq is less picky.

# Default parameters
unset in_dir
out_dir="out"
ampmin=180
ampmax=500
minoverlap=70
maxoverlap=70
incrementoverlap=5

# Get options from compand line arguments. d is requrired.
while getopts d:o:a:b:p:q:r: flag
do
    case "${flag}" in
        d) in_dir=${OPTARG};;
        o) out_dir=${OPTARG};;
        a) ampmin=${OPTARG};;
        b) ampmax=${OPTARG};;
        p) minoverlap=${OPTARG};;
        q) maxoverlap=${OPTARG};;
        r) incrementoverlap=${OPTARG};;
#        \?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
#        :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
#        *) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
# shift $OPTIND-1

# Checks for mandatory argument
#if ! [[ -d $1 ]]
#then
#    echo "-d <in_dir> must be included" >&2
#    exit 1
#fi


# This fastas named in the list with specified overlaps
# List of gene/sequence names
LIST=$(ls "$in_dir" | awk 'BEGIN {FS = "."}{ORS = " "} {print $1}')

# OVERLAPS=(40 45 50 55 60 65 70 75 80 85 90)
OVERLAPS=$(seq -s " " "$minoverlap" "$incrementoverlap" "$maxoverlap")

mkdir $out_dir
for OVERLAP in ${OVERLAPS[@]}; do mkdir ${out_dir}/overlap_$OVERLAP; for GENE in ${LIST[@]}; do primalscheme multiplex -a $ampmin -a $ampmax -n $GENE -t $OVERLAP -o ${out_dir}/overlap_$OVERLAP/$GENE -f fastas/$GENE.fasta; done; done

exit

