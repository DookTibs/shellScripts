#!/bin/bash

# pass in a port number, e.g. "getUnusedPort.sh"
# (if none supplied, start at 1000)
# will spit out the first available port

if [ -z $1 ]; then
	startPort=1000
else
	startPort=$1
fi

# echo "starting from '$startPort'"

while :
do
	# echo "checking port '$startPort'..."
	lsof -i -n -P | grep 127.0.0.1.*LISTEN | sed 's/.*TCP 127.0.0.1:\([0-9]*\) .*/\1/' | grep "^${startPort}$" > /dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo $startPort
		exit 0
	else
		# port is in use; keep looking
		:
	fi
	startPort=$(($startPort+1))
done
# lsof -i -n -P | grep 127.0.0.1.*LISTEN | sed 's/.*TCP 127.0.0.1:\([0-9]*\) .*/\1/' | xargs printf "%05d\n" | sort | uniq

# list of all ports currently in use; zeropadded to 5 digits
# lsof -i -n -P | grep 127.0.0.1.*LISTEN | sed 's/.*TCP 127.0.0.1:\([0-9]*\) .*/\1/' | xargs printf "%05d\n" | sort | uniq

