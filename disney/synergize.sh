#! /bin/bash

# first check to see if we already have a tunnel open
# second grep filters out the "grep" process itself!
if [ ${TOM_OS} = "osx" ]; then
	ps -eax | grep ".*ssh.*localhost:24800" | grep -q -v "grep"
elif [ ${TOM_OS} = "cygwin" ]; then
	# process description on cygwin is a lot more terse...but less ssh stuff in general so this is probably good enough
	ps -eaW | grep -q "ssh"
fi

if [ $? -eq 0 ]; then
	echo "ssh tunnel to personal iMac already open..."
else
	echo "opening ssh tunnel..."
	# ssh -f -N -L localhost:24800:Thomass-iMac-3.local:24800 Thomass-iMac-3.local
	ssh -f -N -L localhost:24800:dooktibs.dnsd.me:24800 dooktibs.dnsd.me
fi

# launch the client
if [ ${TOM_OS} = "osx" ]; then
	cd /Applications/Synergy.app/Contents/MacOS
	./synergyc -n iMacBig -f localhost
elif [ ${TOM_OS} = "cygwin" ]; then
	cd /c/Program\ Files/Synergy/
	./synergyc -n laptop -f localhost
fi

