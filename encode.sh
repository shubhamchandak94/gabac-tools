#! /bin/bash

gabac="/home/fabian/Documents/dev/gabac/build/gabacify"
file=$1
prefix=$2


for filename in *.json; do
echo ${filename}
/usr/bin/time --format="%e %M" -o ${file}.${filename}.encode.time ${gabac} encode -i ${file} -o ${file}.${filename}.out -c ${filename}
if [ $? -ne 0 ]; then
    echo "fail" > ${file}.${filename}.encode.time
    echo "fail" > ${file}.${filename}.decode.time
    rm "${file}.${filename}.out.decoded" "${file}.${filename}.out"
    continue
fi
/usr/bin/time --format="%e %M" -o ${file}.${filename}.decode.time ${gabac} decode -i ${file}.${filename}.out -o ${file}.${filename}.out.decoded -c ${filename}
if [ $? -ne 0 ]; then
    echo "fail" > ${file}.${filename}.encode.time
    echo "fail" > ${file}.${filename}.decode.time
    rm ${file}.${filename}.out.decoded ${file}.${filename}.out
    continue
fi
diff ${file}.${filename}.out.decoded ${file} >> difflog.txt
if [ $? -ne 0 ]; then
    echo "fail" > ${file}.${filename}.encode.time
    echo "fail" > ${file}.${filename}.decode.time
    rm ${file}.${filename}.out.decoded ${file}.${filename}.out
    continue
fi
rm ${file}.${filename}.out.decoded ${file}.${filename}.out
done

for filename in *.time; do
tmp=`cat ${filename}`
echo "${prefix}${filename} ${tmp}" >> total.txt
rm ${filename}
done
