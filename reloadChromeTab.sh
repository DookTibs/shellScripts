#!/bin/bash
if [ -z "$1" ]; then
	echo "Usage: reloadChromeTab \"somePattern\""
else
	chromix load "$1" ; chromix with "$1" reload
fi
