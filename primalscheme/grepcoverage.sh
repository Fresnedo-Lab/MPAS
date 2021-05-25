#cd out
#grep "coverage" */*.log | sed -f / > ../coverage.txt
#tac */*.log | grep -m 1 "coverage" | sed -f / > coverage.txt
#grep "coverage" */*.log | tail -1 | sed -f / > ../coverage.txt
#tac */*.log | grep -m1 "coverage" | sed -f / > coverage.txt

FILE=coverage.txt
if test -f "$FILE"; then
    rm $FILE
fi

for name in overlap_*/*/*.log; do
    grep -H "coverage" "$name" | tail -n 1 | sed -f / >> ./coverage.txt
done

awk 'BEGIN {FS = "/| |, |overlap_"}{OFS = "\t"} {print $3, $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $NF, $2}' coverage.txt > coverage.tsv


#{FNR>-1}{NR>-1} 
#| tr " " "\t"

#grep "coverage" */*.log | cut -d  / -f 1
#grep "coverage" */*.log | cut -d \  -f 11-16