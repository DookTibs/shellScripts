#!/bin/bash
# processId=`ps -eax | grep ssh.*9050.*dooktibs | grep -v grep | awk '{ print $1 }'`

if [ "cygwin" = ${TOM_OS} ];then
	# procps not installed by default in cygwin
	processId=`procps all | grep ssh.*$_VNC_LOCAL_PORT.*$_TJF_HOME_VNC_PORT.*$_TJF_HOME_SSH_PORT.*$_TJF_HOME_USERNAME | grep -v grep | awk '{ print $3 }'`
else
	processId=`ps -eax | grep ssh.*9050.*96.42.96.111 | grep -v grep | awk '{ print $1 }'`
fi


if [ -n "${processId}" ]; then
	echo "kill tunnel running as process ${processId}..."
	kill ${processId}
else
	echo "tunnel does not appear to be running..."
fi
