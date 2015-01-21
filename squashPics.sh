#!/bin/bash
inputPath="/Users/tfeiler/Desktop/1966"
outputPath="/Users/tfeiler/Desktop/1966/squashed"

cd "$outputPath"
rm *.jpg

cp $inputPath/*.jpg .

for f in *.jpg
do
		mogrify -geometry 200 -format jpg $f
done

