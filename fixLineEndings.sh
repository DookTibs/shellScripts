#!/bin/bash

# sometimes when switching Git branches Cygwin screws up the line endings on my shell scripts.
# this fixes it.

if [ -z $1 ]; then
	echo "Supply a file to fix"
else
	# fix the line endings
	sed 's///' $1 > $1_TEMP

	# write the contents to the original file. If we do a "mv" instead, we can lose
	# original file permissions ( and these are usually being run on shell scripts)
	cat $1_TEMP > $1

	# delete the temp file
	rm $1_TEMP
fi
