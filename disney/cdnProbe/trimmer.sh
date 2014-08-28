#! /bin/bash

USAGE="Usage: ./trimmer.sh <file_containing_urls_to_test> <file_for_results>"

# did user supply necessary arguments to script?
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "${USAGE}"
	exit 1
fi

# does input file exist?
if [ -e "$1" ]
then
	if [ -e "$2" ]; then
		echo "result file already exists; exiting without doing any work"
		# exit 1
	fi

	# set up the output file
	echo "" > ${2}

	# start looping...
	urlCounter=1
	while read loopUrl; do
		# echo "loop url [${loopUrl}"
		if [[ $loopUrl =~ \..*/(.*)\.(.*) ]]; then
			echo "${loopUrl}" >> ${2}
		fi
	done < ${1}

	echo "done; check ${2} for output"

else
	echo "Input file does not exist!"
	exit 1
fi
