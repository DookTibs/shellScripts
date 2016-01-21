#!/bin/bash
if [ -z "$1" ]; then
	echo "Usage: reloadBrowserTab \"somePattern\" (chrome|ff)"
else
	if [ -z "$2" ]; then
		browser="chrome"
	else
		browser="$2"
	fi

	if [ "$browser" = "chrome" ]; then
		chromix load "$1" ; chromix with "$1" reload
	elif [ "$browser" = "ff" ]; then
		firefoxReloader.scpt "$1"
	else
		echo "Supported browsers: 'chrome', 'ff'"
	fi
fi
