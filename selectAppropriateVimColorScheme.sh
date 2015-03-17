#!/bin/bash

# I want to use the solarized vim theme, but only if I am on
# my machine with correct stuff installed. If I am ssh'ed in from
# a loaner or something I want to use a more robust theme that looks ok
# even without custom installs, like torte.
#
# unfortunately given the client/server nature of tmux it's a little
# tough to decide where a given client is coming from (and in fact there
# may well be multiple clients attached!). A usually reasonable solution
# is instead to see if ANYONE is ssh'ed in. If so, use torte. If not,
# use solarized. 99 times out of 100 if I am ssh'ed in it's b/c I'm on
# that loaner. That 100th time that I am ssh'ed in for some other reason but
# actually am editing from my physical computer, I can live with having
# to type :colorscheme solarized manually.

# anyway, tl;dr, my .vimrc calls this script to decide what scheme to use.

atCarleton=`echo ${HOSTNAME} | grep "carleton.edu"`
if [ "${atCarleton}" == "" ]; then
	echo "torte"
else
	sshIndicator="tripoli.its.carleton.edu"
	who | grep -q $sshIndicator

	if [ $? -eq 1 ]; then
		echo "solarized"
	else
		echo "torte"
	fi
fi
