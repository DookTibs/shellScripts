#!/bin/bash
# processId=`ps -eax | grep ssh.*9050.*dooktibs | grep -v grep | awk '{ print $1 }'`

searchString="ssh.* -L .*$1.*$2.*$3.*$4"

echo "Searching for open ssh local port forwarding tunnels..."

if [ "cygwin" = ${TOM_OS} ];then
	procps all | grep "$searchString" | grep -v grep
else
	ps -eax | grep "$searchString" | grep -v grep
fi

if [ $? -eq 1 ]; then
	echo "No tunnels appear to be running"
fi
