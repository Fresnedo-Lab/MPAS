# get the primers form primal scheme into a single file with the names of the genes

cd /Users/aperium/Documents/GitHub/Primal-to-Fluidigm/fluidigm_pool_design/scripts
# cd

mkdir ../out

# set file name and clear existing file
FILE=../out/allprimers.tsv
if test -f "$FILE"; then
	rm $FILE
fi


# pull all of the primalscheme primers into a temporary file
LIST=(../../primalscheme/overlap_70/*/*.primer.tsv)
for name in ${LIST[@]}; do
	(awk 'BEGIN{FS = "\t"}{OFS="\t"}NR>1{print FILENAME,$1,$2,$3,$4,$5,$6}' $name) >> $FILE.tmp
done

# prepare the column headers for the new file
(awk 'BEGIN{OFS="\t"}NR<=1{print "gene",$0}' ${LIST[1]}) > $FILE

# fill the new file with the primer data and clean up the "gene" and "name" columns
awk 'BEGIN{FS="\t|/"}{OFS="\t"}{print $5,$7,$8,$9,$10,$11,$12}' $FILE.tmp >> $FILE

# delete the temporary file
rm $FILE.tmp
