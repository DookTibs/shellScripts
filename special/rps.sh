#! /bin/bash

# Reason Package Switcher
# I frequently find myself wanting to jump between a directory in reason_package_local and it's 
# equivalent in reason_package. The hierarchies are a little different which makes life a little 
# annoying. For instance, modules can be found in either:
# reason_package_local/local/minisite_templates/modules/
# or 
# reason_package/reason_4.0/lib/core/minisite_templates/modules/
#
# This script is an attempt to build a generic means of switching between these two trees quickly.
#
# if you pass argument "info" to it, it will NOT switch but will instead just return the dir it would
# otherwise have switched to.

reallySwitch=1
if [ "$1" = "info" ]; then
	reallySwitch=0
fi

currDir=`pwd`
echo ${currDir} | egrep -q "reason_package_local"
inLocalPackage=$?

if [ ${inLocalPackage} -eq 0 ]; then
	# echo "we are in local [${currDir}]..."
	destDir=`echo ${currDir} | sed "s-reason_package_local/local-reason_package/reason_4.0/lib/core-"`
	portion=`echo ${currDir} | sed "s-.*reason_package_local/local/--"`
	beforeDescriptor="LOCAL"
	afterDescriptor="CORE"
else
	# echo "we are in core [${currDir}]..."
	destDir=`echo ${currDir} | sed "s-reason_package/reason_4.0/lib/core-reason_package_local/local-"`
	portion=`echo ${currDir} | sed "s-.*reason_package/reason_4.0/lib/core/--"`
	beforeDescriptor="CORE"
	afterDescriptor="LOCAL"
fi

# echo "DESTDIR [${destDir}]"
# echo "PORTION [${portion}]"

# destDir=${currDir}

if [ "${destDir}" = "${currDir}" ]; then
	outputMsg="no directory change; are you in a Reason installation?"
else
	if [ -d "${destDir}" ]; then
		if [ $reallySwitch -eq 1 ]; then
			cd ${destDir}
			outputMsg="switched from ${beforeDescriptor} => ${afterDescriptor} for [${portion}]..."
		else
			# declare -x RPS="${destDir}"
			outputMsg="${destDir}/"
		fi
	else
		outputMsg="${afterDescriptor} destination directory [${destDir}] does not exist; staying in ${beforeDescriptor}..."
	fi
fi

echo ${outputMsg}
