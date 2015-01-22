#!/bin/bash

# NOTE - this script runs in a loop - kick it off in its own terminal and then
# CTRL-C it to stop it (it will perform some cleanup when cancelled this way)

# INSTRUCTIONS FOR DOING SOMETHING USEFUL WITH THIS SCRIPT...this takes about 10 minutes to do.
#
# 1. ON MY LOANER, INSTALL BREW (this will likely also install the Xcode developer tools)
# 	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#	brew doctor
#
# 2. INSTALL NODE
#	brew install node
#
# (for 3-4, see http://chromix.smblott.org/#_installation)
#
# 3. INSTALL CHROMI EXTENSION IN CHROME BROWSER
#	https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo
#
# 4. INSTALL CHROMIX SERVER
#	sudo npm install -g chromix
#
# now you can do something like have Vim in my office tmux session fire off a command that goes
# over netcat to my loaner laptop and reloads the webpage. Neat!
# 
# I have a nice function defined in functions.vim so in my vimrc I can just setup:
# 	map \ :call SendNetcatCommand("<LOANER_MACHINE_IP>", <LOANER_MACHINE_PORT>, "something")<enter>
# 
# on a per-loaner basis I can set what commands I care about, see "random" below as an example

# This script creates a fifo (named pipe) and then runs netcat on port 2999, redirecting output
# to this named pipe. Then it reads commands coming over netcat and does something with them.
#
# if one were completely trusting, could just pass these along to bash. In our case, we'll listen
# for some very particular things and do some very particular things in response - we are NOT
# going to allow arbitrary stuff to be executed over netcat!
# 
# this is hopefully not too dangerous...

# PART ONE - create the named pipe
namedPipe="/tmp/netcat2999"
rm ${namedPipe}
mkfifo ${namedPipe}

# PART TWO - kick off my listeners
nc -k -l 2999 > ${namedPipe} &
netcatPid=$!

chromix-server &
chromixPid=$!

# WATCH FOR CTRL-C - this is the only way to kill it
trap ctrl_c INT
function ctrl_c() {
	echo "user cancelled; kill ${netcatPid} and ${chromixPid}, and rm ${namedPipe}..."
	kill ${netcatPid}
	kill ${chromixPid}
	rm ${namedPipe}
	exit
}

echo "started netcat with pid ${netcatPid} and chromix with pid ${chromixPid}"

# PART THREE - handle commands coming in over netcat
while true
do
    if read line <$namedPipe; then
        echo "READ LINE FROM NETCAT: [${line}]"
        if [[ "$line" == 'random' ]]; then
			echo "command 'random' means reload random.org..."
			chromix with 'random.org' reload
        elif [[ "$line" == 'carleton' ]]; then
			echo "command 'carleton' means reload carleton.edu"
			chromix with 'carleton.edu' reload
		else
			echo "(unsupported command)"
        fi
    fi
done
