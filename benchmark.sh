rm total.txt
rm difflog.txt

for filename in *.input; do
echo ${filename}
./encode.sh ${filename} "run1${filename}."
./encode.sh ${filename} "run2${filename}."
./encode.sh ${filename} "run3${filename}."
done
