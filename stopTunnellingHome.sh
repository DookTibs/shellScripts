#!/bin/bash
# processId=`ps -eax | grep ssh.*9050.*dooktibs | grep -v grep | awk '{ print $1 }'`
processId=`ps -eax | grep ssh.*9050.*96.42.96.111 | grep -v grep | awk '{ print $1 }'`

if [ -n "${processId}" ]; then
	echo "kill tunnel running as process ${processId}..."
	kill ${processId}
else
	echo "tunnel does not appear to be running..."
fi
