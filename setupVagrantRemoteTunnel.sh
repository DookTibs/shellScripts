#!/bin/bash

# I prefer to develop using a local Vagrant VM, accessible from my local
# desktop at 192.168.50.50. But sometimes it is useful to be able to 
# demo stuff on this while away from the office. This script attempts to
# make this easy. It first ssh'es to my desktop (going through the Carleton
# ssh gateway), and then ssh'es back to the originating machine, setting
# up remote port forwarding.
#
# The end result is that, given a loaner laptop that runs this script, 
# I can, on that loaner, do "https://localhost:9001/reason/" and see my
# Vagrant instance.
#
# Requires ssh to be turned on on this machine and the desktop
# Only runs on OSX.

clear

this_machine_ip=`ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | grep -v 192.168 | grep -v '\<10\.'`
my_username=`whoami`

gateway="ssh-gw.its.carleton.edu"
desktop="tfeiler57864.acs.carleton.edu"
local_port="9001"
vagrant_ip="192.168.50.50"
https_port="443"

cmd="ssh -t ${gateway} ssh -t ${desktop} ssh -R ${local_port}:${vagrant_ip}:${https_port} -N ${my_username}@${this_machine_ip}"

echo "cmd will be: [${cmd}]"
echo ""
echo "You will get three identical ssh password prompts, for:"
echo "	1. the ssh gateway (${gateway})"
echo "	2. your desktop computer (${desktop})"
echo "	3. hopping back to this machine (${this_machine_ip})"
echo ""
echo "Obviously you must have ssh enabled on both your desktop and this machine."
echo ""
echo "After 3 successful logins you will be left as if things have hung. The tunnel is open; just CTRL-C to kill it when you're finished."
echo ""
echo "While open, you can access 'https://localhost:9001/reason' and you will be hitting the Vagrant instance running back on your desktop."
echo ""

${cmd}
