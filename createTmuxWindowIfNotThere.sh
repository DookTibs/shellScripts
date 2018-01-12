# /bin/bash

# simple shell script. If a window with supplied name exists, do nothing.
# else, create it.

if [ -z $1 ]; then
	echo "No window name supplied"
	exit 0
else
	# list the names of all windows in this session
	# and look for an exact match
	tmux list-windows -F '#W' | grep -q "^$1\$"

	if [ $? -eq 0 ]; then
		# echo "window '$1' exists already"
		# colon is null op, like "pass" in python
		:
	else
		# -d means don't switch to it, -n specifies name
		tmux new-window -d -n "$1"
	fi

fi
