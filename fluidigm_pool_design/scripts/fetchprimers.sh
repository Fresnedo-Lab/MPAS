#!/bin/bash

# name: runprimalscheme2.sh
# author: Daniel R. Williams
# date: 30 May 2021

# Description:
# This script gets the primers form primal scheme into a single file with the names of the genes
#
#
# input:
# output:
#
# example command:  shell fetchprimes.sh -d <in_dir> -o <out.tsv>

# Default parameters
unset in_dir
out="out.tsv"

# Get options from compand line arguments. d is requrired.
while getopts d:o: flag
do
    case "${flag}" in
        d) dir=${OPTARG};;
        o) out=${OPTARG};;
#        \?) echo "Unknown option: -$OPTARG" >&2; exit 1;;
#        :) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
#        *) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

# cd /Users/aperium/Documents/GitHub/Primal-to-Fluidigm/fluidigm_pool_design/scripts
# cd

#mkdir ../out

# set file name and clear existing file
FILE="${out}"
if test -f "$FILE"; then
	rm $FILE
fi


# pull all of the primalscheme primers into a temporary file
#LIST=(../../primalscheme/overlap_70/*/*.primer.tsv)
LIST=$(ls ${dir}/*/*.primer.tsv)
for name in ${LIST[@]}; do
	(awk 'BEGIN{FS = "\t"}{OFS="\t"}NR>1{print FILENAME,$1,$2,$3,$4,$5,$6}' "${name}") >> ${FILE}.tmp
done


# prepare the column headers for the new file
set -- $LIST
(awk 'BEGIN{OFS="\t"}NR<=1{print "gene",$0}' $1) > "${FILE}"


# fill the new file with the primer data and clean up the "gene" and "name" columns
awk 'BEGIN{FS="\t|/"}{OFS="\t"}{print $5,$7,$8,$9,$10,$11,$12}' "${FILE}.tmp" >> "${FILE}"


# delete the temporary file
#rm "${FILE}.tmp"
