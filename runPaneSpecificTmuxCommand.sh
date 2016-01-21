#!/bin/bash

# WHAT IS THIS?
# tmux lets you customize its statusline in various ways including by running commands. For instance:
#
# set -g status-right "#(date)"
#
# will run the "date" command and put the results in the status bar.
# however, if you do:
#
# set -g status-right "#(pwd)"
#
# you'll see that the working directory is set to whatever it was when the session was launched. This is not
# a problem for date, but if you are jumping between projects or switching projects after session creation, it's 
# not great.
#
# I wanted to be able to display the current Git branch and this is my attempt to do it. We need to figure out
# what tmux session(s) we're attached to, what the current tmux window is, what pane is active, and what it's
# working directory is. That's this script's responsibility. It then runs whatever was passed into it. The idea is
# that this script is generic and could be used to run any pane-specific command for tmux, and then I can 
# write simpler scripts to chain into it.
#
# So for example, in a tmux config you could do:
#  set -g status-right "#(~/development/shellScripts/runPaneSpecificTmuxCommand.sh ~/development/shellScripts/showGitBranch.sh)"
#
# this script sets a TJF_TMUX_PANE_ASTERISK environment variable to warn if there is more than one
# attached session. I can't find a way to tie the call to the tmux session it originated from (I had hopes of
# using an env variable but got nowhere) so for now we print out a warning message. If you ARE attached to multiple
# sessions, this script and the slave it eval's may well be reporting info on session B while you look at session X.

if [ "$*" == "" ]; then
	echo "No pane-specific command specified";
	exit 1;
fi

numSessionsAttached=`tmux ls | grep "(attached)" | wc -l | xargs` # xargs to trim whitespace

if [ ${numSessionsAttached} -gt 1 ]; then
	declare -x TJF_TMUX_PANE_ASTERISK="(warning - attached to ${numSessionsAttached} sessions) "
else
	declare -x TJF_TMUX_PANE_ASTERISK=""
fi

# 1. what session(s) are we attached to?
attachedSession=`tmux ls | grep "(attached)" | awk -F ":" '{print $1}' | head -n 1`

if [ "${attachedSession}" == "" ];then
	echo "n/a";
else
	# 2. in that session, what is the active window? (don't actually need to know this part - when
	#    running a command on a session, tmux defaults to active window)

	# 3. in the active window, what's the active pane (more accurately, what is it's current working directory?)
	# tmux list-panes -F 'sessionName=[#S] windowIndex=[#I] windowName=[#W] paneIdx=[#P] paneId=[#D] flags=[#F] active=[#{pane_active}] pwd=#{pane_current_path}' -t "HACKYDACK"

	activeDir=`tmux list-panes -F '#{pane_active}  #{pane_current_path}' -t "${attachedSession}" | awk '$1==1 {print $2}'`

	# once we have the dir it's a matter of cd'ing there...
	cd "${activeDir}"

	# ...and running the command
	eval "$*"
fi
