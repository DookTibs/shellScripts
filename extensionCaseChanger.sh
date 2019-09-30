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


if [ -z $2 ]; then
	echo "no file specified"
	exit 1
else
	if [ -f $2 ]; then
		fileToProcess=$2
	else
		echo "invalid input file specified"
		exit 1
	fi
fi

nameAndDot=`echo "$fileToProcess" | sed -e 's-\(.*\)\.\(.*\)-\1.-'`
extension=`echo "$fileToProcess" | sed -e 's-\(.*\)\.\(.*\)-\2-'`

if [ "$caseToUse" == "upper" ]; then
	fixedExtension=`echo "$extension" | tr '[:lower:]' '[:upper:]'`
else
	fixedExtension=`echo "$extension" | tr '[:upper:]' '[:lower:]'`
fi

targetFilename="${nameAndDot}${fixedExtension}"

if [ "$targetFilename" == "$fileToProcess" ]; then
	echo "no rename needed"
	exit
fi

echo "renaming [$fileToProcess] to [$targetFilename]..."
mv "$fileToProcess" "$targetFilename"
