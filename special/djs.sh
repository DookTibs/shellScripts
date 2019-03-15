#! /bin/bash

# Django Switcher, for EPA HAWC. Modified from my old Reason Package Switcher that I used at Carleton
# For a given part of a Django project, I am frequently switching between
#		* the Python code	(Ex: /Users/tfeiler/development/hawc/epahawc/project/study)
#		* templates			(Ex: /Users/tfeiler/development/hawc/epahawc/project/templates/study)
#		* JavaScript		(Ex: /Users/tfeiler/development/hawc/epahawc/project/assets/study)
#
# This script is an attempt to build a generic means of switching between these trees quickly.
#
# this is aliased to "dj" in my ICF bash configuration, so typing that at a prompt will cycle me through
# these locations. You can optionally pass in a particular switchStrategy; so I can do:
#
#		dj		cycle through
#		djt		jump to templates
#		djp		jump to python
#		djj		jump to javascript

currDir=`pwd`

switchStrategy="default"
if [ "$1" = "templates" ]; then
	switchStrategy="${1}"
elif [ "$1" = "python" ]; then
	switchStrategy="${1}"
elif [ "$1" = "javascript" ]; then
	switchStrategy="${1}"
fi

echo ${currDir} | egrep -q "epahawc/project/assets"
inAssets=$?

echo ${currDir} | egrep -q "epahawc/project/templates"
inTemplates=$?

echo ${currDir} | egrep -q "epahawc/project"
inProject=$? # note this will be 0 even if also in assets/templates. so check them first.

# echo "dir=[${currDir}], proj=[${inProject}], templates=[${inTemplates}], assets=[${inAssets}]"

if [ ${inTemplates} -eq 0 ]; then
	beforeDescriptor="TEMPLATES"
	project=`echo ${currDir} | sed "s-.*epahawc/project/templates/\([^/]*\).*-\1-"`
	# destDir=`echo ${currDir} | sed "s-\(.*epahawc/project/\).*-\1assets/${project}/-"`

	if [ "${switchStrategy}" == "default" ]; then
		switchStrategy="javascript"
	fi
elif [ ${inAssets} -eq 0 ]; then
	beforeDescriptor="JAVASCRIPT"
	project=`echo ${currDir} | sed "s-.*epahawc/project/assets/\([^/]*\).*-\1-"`
	# destDir=`echo ${currDir} | sed "s-\(.*epahawc/project/\).*-\1${project}-"`

	if [ "${switchStrategy}" == "default" ]; then
		switchStrategy="python"
	fi
elif [ ${inProject} -eq 0 ]; then
	beforeDescriptor="PYTHON"
	project=`echo ${currDir} | sed "s-.*epahawc/project/\([^/]*\).*-\1-"`
	# destDir=`echo ${currDir} | sed "s-\(.*epahawc/project/\).*-\1templates/${project}/-"`

	if [ "${switchStrategy}" == "default" ]; then
		switchStrategy="templates"
	fi
else
	echo "Could not determine project for [${currDir}]"
fi

if [ "${switchStrategy}" == "python" ]; then
	afterDescriptor="PYTHON"
	destDir=`echo ${currDir} | sed "s-\(.*epahawc/project/\).*-\1${project}-"`
elif [ "${switchStrategy}" == "templates" ]; then
	afterDescriptor="TEMPLATES"
	destDir=`echo ${currDir} | sed "s-\(.*epahawc/project/\).*-\1templates/${project}/-"`
elif [ "${switchStrategy}" == "javascript" ]; then
	afterDescriptor="JAVASCRIPT"
	destDir=`echo ${currDir} | sed "s-\(.*epahawc/project/\).*-\1assets/${project}/-"`
fi

reallySwitch=1

if [ "${beforeDescriptor}" == "${afterDescriptor}" ]; then
	outputMsg="no directory change"
else
	if [ -d "${destDir}" ]; then
		if [ $reallySwitch -eq 1 ]; then
			cd ${destDir}
			outputMsg="switched from ${beforeDescriptor} => ${afterDescriptor} for [${project}]..."
		else
			outputMsg="${destDir}/"
		fi
	else
		outputMsg="${afterDescriptor} destination directory [${destDir}] does not exist; staying in ${beforeDescriptor}..."
		exit 0
	fi
fi

echo ${outputMsg}
pwd
