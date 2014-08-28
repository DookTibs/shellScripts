#!/bin/bash

defaultMount="";
if [ -z "${1}" ]; then
	defaultMount="fakeMount"
else
	defaultMount="${1}"
fi

read -p "Enter local mount point/volume name (${defaultMount}): " mountPoint
if [ -z "${mountPoint}" ]; then
	mountPoint="${defaultMount}"
fi

# echo "proceeding with mount point [$mountPoint]"

fullDir="/Users/tfeiler/remotes/$mountPoint"

# echo "full dir is [$fullDir]"

processId=`pgrep -lf "sshfs.* $fullDir " | awk '{ print $1 }'`

# echo "got processId $processId for mount point $mountPoint"

if [ -n "${processId}" ]; then
	echo "Killing process $processId..."
	kill -9 ${processId}

	echo "sudo force umount '$fullDir'"
	sudo umount -f $fullDir
else
	echo "This mount point does not appear to have sshfs running..."
fi
