# /bin/bash

if [ -z $1 ]; then
	recentIdx=1
else
	recentIdx=$1
fi

git log | grep "^commit " | awk '{ print $2 }' | head -n $recentIdx | tail -n 1
