#!/bin/bash

# dunno why I wrote this? Seems to take SESSION:window.pane, or window.pane, or pane,
# and kills it (with some potentially extraneous CTRL-C's. Why would I need this? WHo knows?!?!

if [ ! -z "$1" ]; then
	justPane=`echo "$1" | sed 's/.*\.//'`
	oneBasedIndex=$(($justPane + 1))
	# tmux orders panes from 0; sed orders lines from 1
	echo "'$1' -> '$justPane'; $oneBasedIndex"

	cmdInPane=`tmux list-panes -t $1 -F '#{pane_current_command}' | sed "${oneBasedIndex}q;d"`

	if [ "$cmdInPane" == "bash" ]; then
		tmux send-keys -t $1 ""
	else
		tmux send-keys -t $1 ""
		tmux send-keys -t $1 ""
		tmux send-keys -t $1 ""
	fi
fi
