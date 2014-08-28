#! /bin/bash

# NOT REALLY USED - JUST KEEPING AROuND FOR NOW IN CASE I CHANGE MY APPROACH

# sometimes we want a clean way to kill a shell that is doing some listening
# to a named pipe. For instance say I am editing a Node.js server in vim
# and I want to repeatedly kill/restart the server in another tmux pane. I can
# start via "listenForVimCommands.sh N" and then "killVimListeners.sh N" to stop it

# would be easier just to store the pid when we fire one of these off, but
# for whatever reason two processes get kicked off so that's not enough.

# ps | grep "listenForVimCommands.sh N" | grep -v grep

if [ -z $1 ]; then
	listenerCmd="/listenForVimCommands.sh"
else
	listenerCmd="/listenForVimCommands.sh ${1}"
fi

echo "Killing [${listenerCmd}]"

kill $(ps | grep "${listenerCmd}" | grep -v grep | awk '{print $1}')
