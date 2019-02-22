#! /bin/bash

############ Parameters
gabac="/home/fabian/Documents/dev/gabac/build/bin/gabacify"
jsonpath="../wordsize1/*.json ../wordsize2/*.json ../wordsize4/*.json ../wordsize8/*.json"
file=$1
prefix=$2


############ Avoid deleting existing results
if [ -f ${prefix}total.txt ]; then
    echo "${prefix}total.txt already existing!"
    exit 1
fi

############ Compression
for filename in ${jsonpath}; do
echo ${filename}
basename=$(basename -- "$filename")


###### Encoding
echo "/usr/bin/time --format="%e %M" -o ${file}.${basename%.json}.encode.time ${gabac} encode -i ${file} -o ${file}.${basename}.out -c ${filename}"
/usr/bin/time --format="%e %M" -o ${file}.${basename}.encode.time ${gabac} encode -i ${file} -o ${file}.${basename}.out -c ${filename}
if [ $? -ne 0 ]; then
    echo "-1 -1" > ${file}.${basename}.encode.time
    echo "-1 -1" > ${file}.${basename}.decode.time
    rm "${file}.${basename}.out.decoded" "${file}.${basename}.out"
    continue
fi

###### Decoding
echo "/usr/bin/time --format="%e %M" -o ${file}.${basename}.decode.time ${gabac} decode -i ${file}.${basename}.out -o ${file}.${basename}.out.decoded -c ${filename}"
/usr/bin/time --format="%e %M" -o ${file}.${basename}.decode.time ${gabac} decode -i ${file}.${basename}.out -o ${file}.${basename}.out.decoded -c ${filename}
if [ $? -ne 0 ]; then
    echo "-1 -1" > ${file}.${basename}.encode.time
    echo "-1 -1" > ${file}.${basename}.decode.time
    rm ${file}.${basename}.out.decoded ${file}.${basename}.out
    continue
fi

###### Check if compression was actually lossless
diff ${file}.${basename}.out.decoded ${file}
if [ $? -ne 0 ]; then
    echo "-1 -1" > ${file}.${basename}.encode.time
    echo "-1 -1" > ${file}.${basename}.decode.time
    rm ${file}.${basename}.out.decoded ${file}.${basename}.out
    continue
fi
rm ${file}.${basename}.out.decoded ${file}.${basename}.out
done
############ Compression end

############ Accumulate results
for filename in *.time; do
tmp=`cat ${filename}`
 y=${filename%.time}
echo "${y##*/} ${tmp}" >> ${prefix}total.txt
rm ${filename}
done

exit 0
