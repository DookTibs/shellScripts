#!/bin/bash

# given a start in a particular directory, print out the name of the current branch and an attempt
# at a sensible name for the relevant repo
branch=`git branch 2>&1 | grep '*' | sed 's/* //'`

if [ "${branch}" == "" ]; then
	echo "${TJF_TMUX_PANE_ASTERISK}n/a";
else
	canonicalRemote=`git remote -v | grep "github.com.*fetch" | sed 's/.*\/\(.*\).git.*/\1/' | head -n 1`

	if [ "${canonicalRemote}" == "" ]; then
		canonicalRemote=`git remote -v | grep "fetch" | sed 's/.*\/\(.*\).git.*/\1/' | head -n 1`
	fi

	echo "${TJF_TMUX_PANE_ASTERISK}${canonicalRemote}:${branch}"
fi
