#!/bin/bash
echo "DISABLED"
exit 1
lastChangeToSourceDirFile="/tmp/carleton_dev_syncer.txt"
let delayThreshold=1000 # number of ms we want to wait before kicking off an rsync
sleepAmount=".1"

if [ "${1}" == "copy" ]; then
	echo "Checking monitor file... (start with no arguments to run in watch mode)"

	while true; do
		if [ -e "${lastChangeToSourceDirFile}" ]; then
			currentTime=`gdate +%s%N | cut -b1-13`
			lastMarkedTime=`cat ${lastChangeToSourceDirFile}`
			let timeElapsed=${currentTime}-${lastMarkedTime}

			echo "[${timeElapsed}] ms elapsed since file was updated..."
			if [ ${timeElapsed} -gt ${delayThreshold} ]; then
				rm "${lastChangeToSourceDirFile}"
				cd ~/development/carleton/
				echo "Starting rsync (`date`)..."
				rsync -r -q --exclude ".git" --exclude ".swp" --delete carleton.edu/ tfeiler@wsgdev05.its.carleton.edu:/var/www/apps/
				echo "done! (`date`)"
			fi
		fi
		sleep "${sleepAmount}"
	done
else
	echo "Watching source directory (start with 'copy' arg to run in alternate mode)"
	fswatch -o -0 ~/development/carleton/carleton.edu | xargs -0 -I {} -P 100 -n 1 sh -c 'gdate +%s%N | cut -b1-13 > /tmp/carleton_dev_syncer.txt' --
fi
