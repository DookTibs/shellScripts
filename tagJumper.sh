#!/bin/bash

# takes a tag like "AssessmentService" or "User" - checks the tags file for
# a single exact match. If found, jump to it. Else, default to normal Vim behavior.
#
# (basically NeoVim is stupid; searching for a tag "User" via the :ta command 
# often searches for other tags with "User" in the name like "UserRepository" or
# whatever (interestingly, CTRL-] seems consistently good!). This was enver a problem
# in old Vim, at least that I can recall.
#
# This script is part of a workaround -- if it finds a single exact match it jumps
# right to it. Otherwise returns a non-zero exit code, and the VimScript hooking into
# this falls back to default behavior.

# step 1 - did they ask for a tag?
if [ -z $1 ]; then
	echo "No tag specified; exiting..."
	exit 1
fi

# step 2 - look in this directory and in any parents for a .tibsJsonTags file.
source ~/development/configurations/bash/functions.bash
baseDir=`find-up .tibsJsonTags`

if [ "$baseDir" == "" ]; then
	# no json tags file found
	echo "No .tibsJsonTags file found; exiting..."
	exit 1
fi

# step 3 - check the tags file for an exact match.
cd $baseDir

matchingTagEntries=`cat .tibsJsonTags | jq ". | select(.name == \"$1\")"`

numMatches=`echo "$matchingTagEntries" | jq -s '. | length'`

if [ $numMatches -eq 1 ]; then
	filePath=`echo "$matchingTagEntries" | jq -r '.path'`
	lineNum=`echo "$matchingTagEntries" | jq '.line'`
	# searchPattern=`echo "$matchingTagEntries" | jq '.pattern'`

	# echo "jump to '$filePath' / $lineNum / '$searchPattern'"
	echo "${lineNum}:::${baseDir}/${filePath}:::"
	exit 0
	# Success!
else
	# got 0 or more than 1 match; can't deal with this
	echo "got $numMatches; bad!"
	exit 1
fi
