#!/bin/bash

filemain=$1
filepair=$2

spring="/home/fabian/Downloads/Spring/spring"
genie="/home/fabian/Documents/dev/genie/cmake-build-release/genie"
config="/home/fabian/Documents/dev/genie/gabac_config/"

function testResult {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
        exit $status
    fi
    return $status
}


echo "-> gzip encode"
/usr/bin/time --format="%e %M" -o ${filemain}.gzip.encode.time sh -c "gzip --best -v < ${filemain} > ${filemain}.gz; gzip --best -v < ${filepair} > ${filepair}.gz"
echo "-> gzip decode"
/usr/bin/time --format="%e %M" -o ${filemain}.gzip.decode.time sh -c "gzip -d -v < ${filemain}.gz > ${filemain}.gz.dec; gzip -d -v < ${filepair}.gz > ${filepair}.gz.dec"
wc -c ${filemain}.gz ${filepair}.gz | cut -f 1 -d " " | tail -n 1 > ${filemain}.gzip.size
testResult diff ${filemain} ${filemain}.gz.dec
testResult diff ${filepair} ${filepair}.gz.dec
echo "${filemain} ${filepair} gzip `cat ${filemain}.gzip.encode.time` `cat ${filemain}.gzip.decode.time` `cat ${filemain}.gzip.size`" >> total.txt
rm ${filemain}.gz.dec ${filepair}.gz.dec ${filemain}.gzip.encode.time ${filemain}.gzip.decode.time ${filemain}.gzip.size ${filemain}.gz ${filepair}.gz

echo "-> bzip encode"
/usr/bin/time --format="%e %M" -o ${filemain}.bzip2.encode.time sh -c "bzip2 --best -v < ${filemain} > ${filemain}.bz2; bzip2 --best -v < ${filepair} > ${filepair}.bz2"
echo "-> bzip decode"
/usr/bin/time --format="%e %M" -o ${filemain}.bzip2.decode.time sh -c "bzip2 -d -v < ${filemain}.bz2 > ${filemain}.bz2.dec; bzip2 -d -v < ${filepair}.bz2 > ${filepair}.bz2.dec"
wc -c ${filemain}.bz2 ${filepair}.bz2 | cut -f 1 -d " " | tail -n 1 > ${filemain}.bzip2.size
testResult diff ${filemain} ${filemain}.bz2.dec
testResult diff ${filepair} ${filepair}.bz2.dec
echo "${filemain} ${filepair} bzip2 `cat ${filemain}.bzip2.encode.time` `cat ${filemain}.bzip2.decode.time` `cat ${filemain}.bzip2.size`" >> total.txt
rm ${filemain}.bz2.dec ${filepair}.bz2.dec ${filemain}.bzip2.encode.time ${filemain}.bzip2.decode.time ${filemain}.bzip2.size ${filemain}.bz2 ${filepair}.bz2

echo "-> spring encode"
/usr/bin/time --format="%e %M" -o ${filemain}.spring.encode.time ${spring} -c -i ${filemain} ${filepair} -t 1 -o ${filemain}.spring
echo "-> spring decode"
/usr/bin/time --format="%e %M" -o ${filemain}.spring.decode.time ${spring} -d -i ${filemain}.spring -t 1 -o ${filemain}.spring.dec ${filepair}.spring.dec
wc -c ${filemain}.spring | cut -f 1 -d " " | tail -n 1 > ${filemain}.spring.size
testResult diff ${filemain} ${filemain}.spring.dec
testResult diff ${filepair} ${filepair}.spring.dec
echo "${filemain} ${filepair} spring `cat ${filemain}.spring.encode.time` `cat ${filemain}.spring.decode.time` `cat ${filemain}.spring.size`" >> total.txt
rm ${filemain}.spring.dec ${filepair}.spring.dec ${filemain}.spring.encode.time ${filemain}.spring.decode.time ${filemain}.spring.size ${filemain}.spring ${filepair}.spring


echo "-> genie encode"
/usr/bin/time --format="%e %M" -o ${filemain}.genie.encode.time ${genie} ${filemain} ${filepair} -c ${config}
echo "-> genie decode"
y=${filemain%.fastq}
mv ${y}.genie ${y}.fastq.genie
/usr/bin/time --format="%e %M" -o ${filemain}.genie.decode.time ${genie} ${filemain}.genie -c ${config}
wc -c ${filemain}.genie | cut -f 1 -d " " | tail -n 1 > ${filemain}.genie.size
testResult diff ${filemain} ${filemain}_decompressed_1.fastq
#testResult diff ${filepair} ${filemain}_decompressed_2.fastq
echo "${filemain} ${filepair} genie `cat ${filemain}.genie.encode.time` `cat ${filemain}.genie.decode.time` `cat ${filemain}.genie.size`" >> total.txt
rm ${filemain}_decompressed_2.fastq ${filemain}_decompressed_1.fastq ${filemain}.genie.encode.time ${filemain}.genie.decode.time ${filemain}.genie.size ${filemain}.genie



