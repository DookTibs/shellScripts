#! /bin/bash

# 
# when in a UI folder, extracts the project name and fires off the ant build script for it
#


if [ -z "$1" ]
then
	# attempt to figure out the subproject
	workingDir=`pwd`

	# echo "working dir is [${workingDir}]..."
	subproject=`echo ${workingDir} | sed -n 's-.*cp/trunk/ui/\(.*\)/src.*-\1-p'`
	# echo "subproject is [${subproject}]..."
else
	subproject=${1}
fi

antTarget="Build${subproject}"
# echo "ant target is [${antTarget}]..."

echo "FROM CURRENT PATH, ATTEMPTING TO RUN ANT TARGET FOR CLUBPENGUIN UI: [${antTarget}]..."

if [ ${TOM_OS} = "osx" ]; then
	ant -buildfile ${CLUBPENGUIN}cp/trunk/build/ant/_buildFileAS3.xml $antTarget
elif [ ${TOM_OS} = "cygwin" ]; then
	ant -buildfile `cygpath -m ${CLUBPENGUIN}cp/trunk/build/ant/_buildFileAS3.xml` $antTarget
else
	echo "unsupported platform!"
fi
