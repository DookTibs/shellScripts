#!/bin/bash

if [ -z $1 ]; then
	echo "no case specified"
	exit 1
else
	if [ $1 == "upper" ] || [ $1 == "lower" ]; then
		caseToUse=$1
	else
		echo "invalid case specified"
	fi
fi

let counter=0
for loopFile in "$@"
do
	if [ $counter -gt 0 ]; then
		if [ -f $loopFile ]; then
			fileToProcess=$loopFile

			nameAndDot=`echo "$fileToProcess" | sed -e 's-\(.*\)\.\(.*\)-\1.-'`
			extension=`echo "$fileToProcess" | sed -e 's-\(.*\)\.\(.*\)-\2-'`

			if [ "$caseToUse" == "upper" ]; then
				fixedExtension=`echo "$extension" | tr '[:lower:]' '[:upper:]'`
			else
				fixedExtension=`echo "$extension" | tr '[:upper:]' '[:lower:]'`
			fi

			targetFilename="${nameAndDot}${fixedExtension}"

			if [ "$targetFilename" == "$fileToProcess" ]; then
				echo "no rename needed for $fileToProcess..."
			else
				echo "renaming [$fileToProcess] to [$targetFilename]..."
				mv "$fileToProcess" "$targetFilename"
			fi
		else
			echo "invalid input file specified"
		fi
	fi

	let counter=$counter+1
done

