#!/bin/bash

# example: 'tmuxPrompter.sh "move-window -t" "Enter destination window"
# will prompt the user for input and then run the command. This is not useful
# on its own but can be used in aliases/mappings where we need to take user input
# before running a command. Pretty simple; at the moment will only accept a single
# input value.
#
# if you pass in a third value, will just run the command as is. If not, it will run the prompt

if [ -z "$1" ]; then
	echo "No command supplied"
	exit 1
else
	cmd="$1"
fi

if [ -z "$2" ]; then
	echo "No prompt supplied"
	exit 1
else
	prompt="$2:"
fi

if [ -z "$3" ]; then
	read -p "$prompt " userInputVal
	tmux $cmd $userInputVal
else
	tmux $cmd $3
fi
