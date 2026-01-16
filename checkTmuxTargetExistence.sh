#! /bin/bash

# exit code 0 if the SESSION:WINDOW.PANE / WINDOW.PANE / PANE target exists
# exit code non-zero if doesn't exist, etc.

if [ -z $1 ]; then
	echo "No target supplied"
	exit 1
else
	t=$1

	default_session_name="___not___set___"
	if [[ -n "$TMUX_PANE" ]]; then
		default_session_name=$(tmux list-panes -t "$TMUX_PANE" -F '#S' | head -n1)
	fi

	# what was passed in?
	# tmux targets look like this:
	# SESSION:WINDOW.PANE
	# this script can accept any of these

	if [[ $t == *":"* ]]; then
		target_session=`echo "$t" | sed 's/\(.*\):.*/\1/'`
	else
		if [ $default_session_name != "___not___set___" ]; then
			target_session=$default_session_name
		else
			echo "No session name supplied in target and outside of a tmux session; exiting"
			exit 1
		fi
	fi

	if [[ $t == *"."* ]]; then
		target_window=`echo "$t" | sed 's/\(.*:\)*\(.*\)\..*/\2/'`
	else
		target_window=`tmux display-message -p '#W'`
	fi

	target_pane=`echo "$t" | sed 's/\(.*:\)*\(.*\.\)*\(.*\)/\3/'`

	# echo "run against '${target_session}:${target_window}.${target_pane}'"

	tmux has-session -t $target_session 2>/dev/null

	if [ $? -eq 0 ]; then
		tmux list-windows -F '#W' | grep -q "^$target_window\$"
		if [ $? -eq 0 ]; then
			tmux list-panes -F '#P' | grep -q "^$target_pane\$"

			if [ $? -eq 0 ]; then
				exit 0
			else
				# pane not found
				exit 1
			fi
		else
			# window not found
			exit 1
		fi
	else
		# sess not found
		exit 1
	fi
	
fi
