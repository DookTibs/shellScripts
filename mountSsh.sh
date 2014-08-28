#!/bin/bash

defaultPath="";
defaultMount="";
defaultPort="";
if [ -z "${1}" ]; then
	defaultPath="tfeiler@wsgtest.its.carleton.edu:/var/www/tfeiler/reason-core/"
else
	defaultPath="${1}"
fi

if [ -z "${2}" ]; then
	# defaultMount="/Users/tfeiler/remotes/wsgTfeilerReasonHtml"
	defaultMount="wsgTfeilerReasonCore"
else
	defaultMount="${2}"
fi

if [ -z "${3}" ]; then
	defaultPort="22"
else
	defaultPort="${3}"
fi

read -p "Enter scp path to mount (${defaultPath}): " remotePath
read -p "Enter local mount point/volume name (${defaultMount}): " localMountPoint
read -p "Enter port (${defaultPort}): " remotePort

if [ -z "${remotePath}" ]; then
	remotePath="${defaultPath}"
fi

if [ -z "${localMountPoint}" ]; then
	localMountPoint="${defaultMount}"
fi

volName="${localMountPoint}"
localMountPoint=/Users/tfeiler/remotes/"${localMountPoint}"

if [ -z "${remotePort}" ]; then
	remotePort="${defaultPort}"
fi

# thoughts - be sure to use transform_symlinks so that you can follow those.
#			 should I be seeing if there's a samba mount or something instead of doing all this?

# echo "got remote path [${remotePath}], port [${remotePort}], local dir [${localMountPoint}], volname [${volName}]"
sshfs -p ${remotePort} "${remotePath}" "${localMountPoint}" -oauto_cache,transform_symlinks,reconnect,defer_permissions,negative_vncache,volname="{$volName}"

echo "to unmount later, run 'umount ${localMountPoint}'"
