#!/bin/bash
# connect to mitre and remote port forward
# If I start up simpleCommandServer on my Carleton desktop like:
# ./simpleCommandServer 2500
# 
# then once I'm ssh'ed into mitre I should be able to do:
# 	curl localhost:2499/someUrl
#
# this lets me do stuff like run commands I only have installed on my "real" work machine
# while ssh'ed into somewhere else. For now this is only useful for mitre but
# could easily be generalized so that I could use it in other environments

let localPort=2500
let mappedPort=${localPort}-1

cmd="ssh -R0.0.0.0:${mappedPort}:0.0.0.0:${localPort} mitre.clamp-it.org"
echo "connecting to mitre with remote port forwarding, ${mappedPort} -> ${localPort}"
echo "actual command is [${cmd}]"
echo "(be sure to run './simpleCommandServer.sh 2500', if you want to use 'curl localhost:2499/blah' type commands while on mitre"

${cmd}
