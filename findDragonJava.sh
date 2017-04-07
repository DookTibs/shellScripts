#!/bin/bash
cd /cygdrive/c/Users/38593/workspace/icf_dragon/src/main/java/
# find . -name "*.java" -exec grep -l "$1" {} \;
# ag -l "$1"

# let's use sag
# run this either as:
#
#	# just lists result files
#	findDragonJava "SomeSearch"
#
#	# outputs line contents (-v == 'verbose')
#	findDragonJava "SomeSearch" -v

justList=1
if [ ! -z "${2}" ]; then
	if [ "${2}" == "-v" ]; then
		justList=0
	fi
fi

if [ ${justList} -eq 1 ]; then
	sag -l "$1" | sed 's/cygdrive.*src\/main\/java\///'
else
	sag "$1" | sed 's/cygdrive.*src\/main\/java\///'
fi
