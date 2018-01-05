#!/bin/bash

# if tmux/Vim/OS crashes while I have Vim running I get a swap file sticking around.
# Previously this means I would:
# 1. open Vim in recovery mode for the file
# 2. save the file to a temp file
# 3. diff the temp file and the file I am interested in
# 4. if they are the same, remove the temp file and the swap file
#
# I got tired of this so I wrote this script to ease this a bit. Now you run this script
# with the filename. You still need to run Vim in recovery mode and write out the file, but
# this script will attempt to walk you through some of the steps (and it makes it a little less
# likely that you will accidentally delete the wrong file)

# CURRENT PROBLEM - the trick to finding justSavedFile doesn't work right. Sometimes
# Vim file recovery seems to update the original file and sometimes it doesn't so I
# am not sure how to sort of the file listing to get the actual temp file name...

echo "Doensnt work yet"
exit 1

if [ -e "$1" ]; then
	echo "Trying to recover $1..."
	echo "----------"
	vim $1
	justSavedFile=`ls -lt | head -n 3 | tail -n 1 | awk '{print $NF}'`
	echo "just saved file is [$justSavedFile]"

	if cmp -s $1 $justSavedFile; then
		swapFile=".$1.swp"
		echo "All changes were already in original file."
		echo "Probably ok to delete temp comparison file ($justSavedFile) and swap file ($swapFile), proceed?"

		select yn in "Yes" "No"; do
			if [ "$yn" = "Yes" ]; then
				echo "Deleting files..."
				rm $swapFile
				rm $justSavedFile
			else
				echo "Quitting without touching files."
			fi
			exit
		done
	else
		echo "The file you just saved ($justSavedFile) does not match $1. You need to resolve this manually."

	fi

else
	echo "Enter the filename you want to try to recover..."
fi
