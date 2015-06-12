#!/bin/bash
# simple shell script that reads my local IP address and hops
# from a loaner/home/coworker machine to my office machine via
# the public facing shs server.
# Optionally Reverse tunnels along the way and maps back to some port on my loaner.
# Idea here is that I can run a server on some port on my
# loaner (see simpleCommandServer.sh) and access it from my
# office machine on that port minus 2.
# Ex, while ssh'ed into my office I should be able to do:
# 	curl localhost:4015/thisWorks
# and it will hit a Node.js server running back on my 
# loaner on port 4017 (not real port numbers)

source "${HOME}/development/configurations/bash/sensitive_data.bash"

let localPort=${_TJF_LOANER_CMDSERVER_PORT}
myDesktop="${_TJF_OFFICE_HOST}"

if [ "$1" = "-r" ]; then
	let fullyMappedPort=${localPort}-1
	cmd="ssh -R0.0.0.0:${fullyMappedPort}:0.0.0.0:${localPort} $myDesktop"
	echo "on network; connecting to office with remote port forwarding, ${fullyMappedPort} -> ${localPort}"
	echo "actual command is [${cmd}]"
else
	cmd="ssh $myDesktop"
	echo "connecting to office with [$cmd]"
fi

${cmd}
