#!/bin/bash

# shell script that, given some kind of output from git log like "git log" or "git mylog", and
# a positional parameter (1 means appears first in output, 2 means appears second, etc.),
# will return the SHA for that commit.
#
# generally interesting as an example of a script that expects data from stdin, probably via pipe
#
# I use this in combination with other scripts/commands, like:
#
#	# show the files from my second most recent commit
#	git showfiles `git mylog | getNthCommitSha.sh 2`


if [ -n $1 ]; then
	let target=$(($1))
else
	let target=0
fi

if [ $target -le 0 ]; then
	exit 1
fi

let counter=0
regex="^commit [a-z0-9]{40}$"
while read LINE; do
	if [[ "${LINE}" =~ $regex ]]; then
	   let counter=$counter+1
	   if [ $counter -eq $target ]; then
		   echo "${LINE}" | awk '{print $2}'   # do something with it here
		   exit 0
	   fi
	fi
done
exit 1
