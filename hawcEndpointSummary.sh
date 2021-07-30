#!/bin/bash

echo "Alternate approach..."
cd $HAWC_HOME

let padWidth=100
if [ -n "$1" ]; then
	let padWidth=${1}
fi

splitData=( $(awk -f ~/development/shellScripts/hawc.awk project/hawc/urls.py) )

prefix=""
nextFile=""
for sd in "${splitData[@]}"
do
	if [ "${prefix}" == "" ]; then
		prefix=$sd
	else
		nextFile="project/$sd"
		nextFile=`echo $nextFile | sed 's/\./\//'`
		nextFile=`echo $nextFile | sed 's/$/.py/'`

		if [ -f $nextFile ]; then
			# echo "WORK ON [$prefix], [$nextFile]"
			awk -v PAD_WIDTH=${padWidth} -v URL_PREFIX=${prefix} -f /Users/tfeiler/development/shellScripts/hawcEndpointHelper.awk "$nextFile"
			exit 1
		fi
		prefix=""
	fi
done

exit 1

cd $HAWC_HOME

let padWidth=100
if [ -n "$1" ]; then
	let padWidth=${1}
fi

urlFiles=( $(find . -name "urls.py") )

# loop through the files and hand them off to the helper awk script
for uf in "${urlFiles[@]}"
do
	# last element has an extra char on it...
	fixedFilename=`echo $uf | sed 's/\.py.*$/.py/'`

	awk -v PAD_WIDTH=${padWidth} -f ~/development/shellScripts/hawcEndpointHelper.awk "$fixedFilename"
done
echo "I NEED TO CHECK hawc/urls.py and add prefixes to these..."
echo "I	want to rewrite things like (?P<pk>\d+) as {pk}..."
echo "I need to account for the order these urls are defined (maybe)..."
