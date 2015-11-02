#!/bin/bash
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Usage: watchAndReloadBrowserTab fileOrDirToWatch \"urlPatternToReload\" (chrome|ff)"
else
	thingToWatch=$1
	urlToLoad=$2
	if [ -z "$3" ]; then
		browserToReload="chrome"
	else
		browserToReload="$3"
	fi

	echo "Watching $thingToWatch for changes; will (re)load '$urlToLoad' in '$browserToReload'"

	# explanation:
	# fswatch
	#		-o : means we emit a number of events, not the files that changed.
	#		-0 : means we separate emitted values by NUL instead of newline
	# xargs
	#		-0 : means we look for NUL separated events
	#		-n 1 : means we run command on every event
	#		-I {} : lets us use {} as a substitute for emitted val (not in use)
	#		reload... : command that gets executed
	fswatch -o -0 "$thingToWatch" | xargs -0 -n 1 -I {} reloadBrowserTab.sh "$urlToLoad" "$browserToReload"

	# note - I couldn't figure out a way to get xargs to run "cmd1 ; cmd2" - 
	# hence the existence of reloadBrowserTab.sh which just contains two commands
fi
