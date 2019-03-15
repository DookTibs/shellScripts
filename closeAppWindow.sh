#!/bin/bash

if [ -z $1 ]; then
	echo "Usage: closeAppWindow <ApplicationName> <WindowName>"
	exit 1
fi

if [ -z $2 ]; then
	echo "Usage: closeAppWindow <ApplicationName> <WindowName>"
	exit 1
fi

osascript << EOF
tell application "$1"
	close (every window whose name is "$2")
end tell
EOF
