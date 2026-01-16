#!/bin/bash

# proof of concept -- if I tee the output of pianobar to output.txt, can I script a way to
# programmatically fetch and select a station? YES!
# bunh of placeholder stuff in here and only playpause and hardcoded station selection work,
# but if I spent some time with this I could get it all working I bet.
#
# 1. run a tmux session PIANOBAR with first window named "pianobar"
# 2. anywhere else, run "controlPianoBar.sh togglerun" or "controlPianoBar.sh launch"

echo `date` >> ~/pianobarexperiments/controlTester.log

# TODO - make this script able to check/kill/start pianobar
# TODO - support station switching

# when running via Stream Deck it must have a shell env where this isn't defined...
tmuxCmd=/opt/homebrew/bin/tmux
tacCmd="tail -r"

if [ -z $1 ]; then
	echo "Usage: controlPianoBar.sh <command> <args>"
	echo "       command is one of:"
	echo "		 launch"
	echo "		 kill"
	echo "		 togglerun"
	echo "		 playpause"
	echo "		 skip"
	echo "		 thumbup"
	echo "		 thumbdown"
	echo "		 stations 'station name'"

else
	userCommand="$1"

	echo "execute pianobar command '$userCommand'"

	simpleTmuxCommand=""

	# TODO - ensure it's even running in that window?

	if [ "$userCommand" == "playpause" ]; then
		echo "playpause!"
		simpleTmuxCommand="p"
	elif [ "$userCommand" == "skip" ]; then
		echo "skip!"
		simpleTmuxCommand="n"
	elif [ "$userCommand" == "launch" ]; then
		runningPianoState=`$tmuxCmd list-panes -t "PIANOBAR:pianobar.0" -F '#{pane_current_command}' | head -n 1`
		if [ "$runningPianoState" == "pianobar" ]; then
			echo "pianobar is already running..."
		else
			echo "start it!"
			$tmuxCmd send-keys -t "PIANOBAR:pianobar.0" "pianobar | tee ~/development/shellScripts/pianoBarLog.txt"
			$tmuxCmd send-keys -t "PIANOBAR:pianobar.0" "Enter"
		fi
	elif [ "$userCommand" == "kill" ]; then
		runningPianoState=`$tmuxCmd list-panes -t "PIANOBAR:pianobar.0" -F '#{pane_current_command}' | head -n 1`
		if [ "$runningPianoState" == "pianobar" ]; then
			echo "kill it!"
			simpleTmuxCommand="q"
		else
			echo "pianobar isn't even running..."
		fi
	elif [ "$userCommand" == "togglerun" ]; then
		runningPianoState=`$tmuxCmd list-panes -t "PIANOBAR:pianobar.0" -F '#{pane_current_command}' | head -n 1`
		if [ "$runningPianoState" == "pianobar" ]; then
			echo "kill it!"
			simpleTmuxCommand="q"
		else
			echo "start it!"
			$tmuxCmd send-keys -t "PIANOBAR:pianobar.0" "pianobar | tee ~/development/shellScripts/pianoBarLog.txt"
			$tmuxCmd send-keys -t "PIANOBAR:pianobar.0" "Enter"
		fi
	elif [ "$userCommand" == "thumbup" ]; then
		echo "like!"
		simpleTmuxCommand="+"
	elif [ "$userCommand" == "thumbdown" ]; then
		echo "dislike!"
		simpleTmuxCommand="-"
	elif [ "$userCommand" == "station" ]; then
		station="$2"
		echo "switch to station '$2'..."

		# step 1 - get list of stations
		$tmuxCmd send-keys -t "PIANOBAR:pianobar.0" "s"

		# step 2 - tail the station list
		stationNum=`python controlPianoBarHelper.py stationnum "$2"`
		echo "station '$2' -> '$stationNum'..." >> ~/pianobarexperiments/controlTester.log
		if [ $? -eq 0 ]; then
			echo "found stationNum '$stationNum'" >> ~/pianobarexperiments/controlTester.log
			
			# step 4 switch to it"
			$tmuxCmd send-keys -t "PIANOBAR:pianobar.0" "$station"
		else
			echo "Unable to switch to '$2'"
		fi

		$tmuxCmd send-keys -t "PIANOBAR:pianobar.0" ""
	fi

	if [ "$simpleTmuxCommand" != "" ]; then
		echo "send '$simpleTmuxCommand' to tmux window..." >> ~/pianobarexperiments/controlTester.log
		$tmuxCmd send-keys -t "PIANOBAR:pianobar.0" "$simpleTmuxCommand"
	fi
fi
