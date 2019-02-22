
#! /bin/bash

############ Parameters
numruns=3

############ Avoid deleting existing results
if [ -f total.txt ]; then
    echo "total.txt already existing!"
    exit 1
fi


############ Run simulation
for filename in $@; do
echo ${filename}
    for (( i = 1; i <= $numruns; i++ )) 
    do
        ./encode.sh ${filename} "run$i."
        if [ $? -eq 1 ]; then
            echo "Encode returned non-zero-status"
            exit 1
        fi
    done
done

############ Split into names, times, memory
cut -d " " -f 1 run1.total.txt > stream_names.txt
for filename in *.total.txt; do
    cut -d " " -f 2 ${filename} > ${filename}.gabac_time
    cut -d " " -f 3 ${filename} > ${filename}.gabac_memory
    rm ${filename}
done

############ Merge times, memory
paste *.gabac_time > total_gabac_time.txt
paste *.gabac_memory > total_gabac_memory.txt
rm *.gabac_time
rm *.gabac_memory

############ Calculate averages
suffix=""
for (( i = 2; i <= $numruns; i++ )) 
do
    suffix="${suffix} + \$${i}"
done
suffix="${suffix})/${numruns})}"
prefixtime='{printf("%.2f\n", ($1'
prefixmemory='{printf("%d\n", ($1'
awk "${prefixtime}${suffix}"  total_gabac_time.txt > total_gabac_time_avg.txt
awk "${prefixmemory}${suffix}" total_gabac_memory.txt > total_gabac_memory_avg.txt
rm total_gabac_time.txt
rm total_gabac_memory.txt

############ Merge results
paste stream_names.txt total_gabac_time_avg.txt total_gabac_memory_avg.txt > total.txt
rm stream_names.txt total_gabac_time_avg.txt total_gabac_memory_avg.txt
sed -i -e 's/-1.00/-1/g' total.txt
sed -i -e 's/-1/fail/g' total.txt

