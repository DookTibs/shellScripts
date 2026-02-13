#!/bin/bash

# what does this do...

function canceller() 
{
	tmux send-keys -t 1 C-c
	tmux send-keys -t 2 C-c
	tmux send-keys -t 3 C-c

	tmux select-pane -t 0 -P "bg=default"
	exit 0
}

if [ -z "$1" ]; then
	echo "Supply a litstream tunnel name (dev, prod, etc.)"
else
	trap 'canceller' SIGINT

	# so we can use our aliases
	# source ~/development/configurations/bash/icf.bash
	# actually no need - we just send-keys to normal bash sessions so we have access to everything...

	tunnel_env="$1"
	echo "Ensure tunnel open-ness for '$tunnel_env'..."
	uppered=`echo "$tunnel_env" | tr '[:lower:]' '[:upper:]'`
	lowered=`echo "$uppered" | tr '[:upper:]' '[:lower:]'`
	echo "'${tunnel_env}' -> '${uppered}' / '${lowered}'"
	
	current_window=`tmux display-message -p '#W'`

	if [ "${current_window}" != "${uppered}" ]; then
		echo "Run this command from a tmux window named $uppered please..."
		exit 1
	else
		checkTmuxTargetExistence.sh "${uppered}.4"
		
		if [ $? -eq 0 ]; then
			echo "Too many panes; close until you have just four; start from 1; etc..."
			exit 2
		else
			# we support 4 panes (probably you already ran this once) or 0 (starting).
			# anything else, too bad.
			
			checkTmuxTargetExistence.sh "${uppered}.3"
			if [ $? -eq 0 ]; then
				echo "Already have a 4 pane setup; done..."
			else
				checkTmuxTargetExistence.sh "${uppered}.1"
				if [ $? -eq 1 ]; then
					# only one window at 0 - make windows 2, 3, 0 (they'll re-order)
					tmux split-window -h
					tmux split-window -v
					tmux select-pane -t 0
					tmux split-window -v -l 50
				else
					echo "Either start with a single pane, or a custom 4 pane setup"
					exit 3
				fi
			fi
		fi
	fi

	tmux select-pane -t 0

	# at this point we have four panes in window named .e.g "DEV", "PROD", etc.
	# Probably with an arrangement like so; and we are in pane 0:
	#
	# +-----+-----+
	# |  0  |     |
	# +-----+  2  |
	# |	    |     |
	# |  1  +-----|
	# |     |     |
	# |     |  3  |
	# |     |     |
	# +-----+-----+
	
	running_cmd_pane_1=`tmux list-panes -F '#{pane_current_command}' | head -n 2 | tail -n 1`

	echo "pane 1 running '${running_cmd_pane_1}'..."
	if [ "${running_cmd_pane_1}" == "Python" ]; then
		echo "tunnel already open..."
	else
		echo "tunnel is closed; try to open it..."
		tmux send-keys -t 1 tunnel_litstream_${lowered} Enter
		sleep 5

		running_cmd_pane_1=`tmux list-panes -F '#{pane_current_command}' | head -n 2 | tail -n 1`
		if [ "${running_cmd_pane_1}" != "Python" ]; then
			echo "Try sso login..."

			sso_login_cmd=`pbpaste`
			echo "login cmd is [$sso_login_cmd]"
			tmux send-keys -t 1 "${sso_login_cmd}" Enter

			# TODO - HARD TO TEST REMAINING BIT -- IF USER WENT THRU AN SSO LOGIN FLOW
			# USING THEIR BROWSER, AS OPPOSED TO IT BEING CACHED AND SUCCEEDING...
			#
			# TODO - another hard one - what to do if tunnel closes...
			saw_aws=0
			while :
			do
				running_cmd_pane_1=`tmux list-panes -F '#{pane_current_command}' | head -n 2 | tail -n 1`
				if [ "${running_cmd_pane_1}" == "aws" ]; then
					saw_aws=1
				fi

				if [ "${running_cmd_pane_1}" == "bash" ] && [ ${saw_aws} -eq 1 ] ; then
					tmux send-keys -t 1 tunnel_litstream_${lowered} Enter
				fi

				if [ "${running_cmd_pane_1}" == "Python" ]; then
					break
				fi
				echo "waiting sso (${running_cmd_pane_1})...Press [CTRL+C] to stop.."
				sleep 1
			done
		else
			echo "NOW tunnel is open..."
		fi
	fi

	echo "Tunnel appears to be open; proceed..."
	sleep 2

	running_cmd_pane_2=`tmux list-panes -F '#{pane_current_command}' | head -n 3 | tail -n 1`
	echo "pane 2 running '${running_cmd_pane_2}'..."
	if [ "${running_cmd_pane_2}" != "watch" ]; then
		tmux send-keys -t 2 "psql_litstream_${lowered}_keepalive" Enter
	else
		echo "postgres keepalive already running most likely..."
	fi

	running_cmd_pane_3=`tmux list-panes -F '#{pane_current_command}' | tail -n 1`
	echo "pane 3 running '${running_cmd_pane_3}'..."
	if [ "${running_cmd_pane_3}" != "watch" ]; then
		tmux send-keys -t 3 "redis_litstream_${lowered}_keepalive" Enter
	else
		echo "redis keepalive already running most likely..."
	fi

	# set the pane to lime green to show things running...
	tmux select-pane -t 0 -P "bg=colour47"

	# keep this running -- when we CTRL-c we'll kill everything else!
	while :
	do
		running_cmd_pane_1=`tmux list-panes -F '#{pane_current_command}' | head -n 2 | tail -n 1`

		echo "Tunnel open (${running_cmd_pane_1}) and keepalive connections running; Press [CTRL-c] to close it all..."
		sleep 60
	done

	# close pane 3
	# tmux killp -t 3
fi
