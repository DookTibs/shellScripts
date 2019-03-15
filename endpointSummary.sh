#!/bin/bash

cd $DRAGON_HOME

# shell script that produces a summary report of all the defined 
# endpoints in DRAGON Online. When tracing down a problem can
# be used to quickly find the relevant controller (and from finding
# the source for that, the template it uses, services it calls, etc.)
#
# by default prints things as it finds them. Useful ways to use it:
#
# endpointSummary.sh
# endpointSummary.sh | sort
# endpointSummary.sh | grep dashboard
#
# this uses a file called "annotationReportCache" that contains the names of
# all files in the codebase that include the @RequestMapping directive.
# This doesn't change all that often, so I leave that file lying around. If you
# delete it (it lives in DRAGON_HOME) this script will recreate it.



# find the files that have the @RequestMapping annotation
if [ ! -f annotationReportCache ]; then
	echo "(regenerating cache file; this takes about 10 seconds...)"
	find . -name "*.java" -exec grep -l "@RequestMapping(" {} \; > annotationReportCache
fi

let padWidth=100
if [ -n "$1" ]; then
	let padWidth=${1}
fi

# readarray works in bash 4; not in older versions
# readarray controllerFiles < annotationReportCache
IFS=$'\n' read -d '' -r -a controllerFiles < annotationReportCache

# controllerFiles=(
	# "./src/main/java/com/icfi/dragon/web/controller/AdminController.java"
# )

# loop through the files and hand them off to the helper awk script
for cf in "${controllerFiles[@]}"
do
	# strip off last character (newline). This worked in Cygwin
	# cf=${cf::-1}

	# this works on OSX - sometimes there's a garbage cahracter, sometimes not.
	# verify that the echo looks right
	cf=`echo $cf | sed 's/[^a]$//'`
	# echo "Input file: $cf"

	awk -v PAD_WIDTH=${padWidth} -f ~/development/shellScripts/endpointHelper.awk "$cf"
done
