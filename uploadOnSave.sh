#!/bin/bash
echo "DISABLED"
exit 0

cd ~/development/carleton/
sshUser=`whoami`
sshHost="wsgdev05.its.carleton.edu"
remoteBaseDir="/var/www/apps/"

if [ "${1}" == "reallyUpload" ]; then
	cd carleton.edu
	# http://backreference.org/2009/12/09/using-shell-variables-in-sed/
	full_path="${3}"
	safe_pattern=$(printf '%s\n' "$2" | sed 's/[[\.*^$/]/\\&/g')
	changedFile=`echo "${full_path}" | sed "s/${safe_pattern}//"`
	changedDir=`dirname ${changedFile}`
	# echo "chaanged : [$changedFile]/[${changedDir}]"

	echo "${changedFile}" | grep -q "\(\.swp$\|\.git\)"

	if [ $? -eq 0 ]; then
		echo "File is Vim .swp, .git, etc....ignore" > /dev/null
	else
		# echo "sync: [${full_path}]...[${changedFile}]"

		if [ -e "${full_path}" ]; then
			if [ -f "${full_path}" ]; then
				# it's a file - scp it to the server
				scp -q "${changedFile}" ${sshUser}@${sshHost}:${remoteBaseDir}/${changedDir}/
			elif [ -d "${full_path}" ]; then
				# it's a directory - ensure it exists on the server
				ssh ${sshUser}@${sshHost} "
					if [ ! -d "${remoteBaseDir}/${changedFile}" ]; then
						mkdir "${remoteBaseDir}/${changedFile}"
					fi
				"
			fi
		else
			# it's something deleted from our local system.
			# if it's a file - delete it. If it's a directory, rm -rf it
			ssh ${sshUser}@${sshHost} "
				if [ -e "${remoteBaseDir}/${changedFile}" ]; then
					if [ -f "${remoteBaseDir}/${changedFile}" ]; then
						rm "${remoteBaseDir}/${changedFile}"
					elif [ -d "${remoteBaseDir}/${changedFile}" ]; then
						rm -rf "${remoteBaseDir}/${changedFile}"
					fi
				fi
			"
		fi
	fi
else
	dir=`pwd`

	if [ "${1}" == "rsync" ]; then
		echo "Starting rsync (`date`)..."
		rsync -r --delete --exclude ".git" --exclude ".swp" carleton.edu/ ${sshUser}@${sshHost}:${remoteBaseDir}/
		echo "done! (`date`)."
	else
		echo "Skipping initial rsync; launch with 'rsync' arg if you want to."
	fi

	echo "Watching for changes in [${dir}]..."


	# explanation:
	# fswatch
	#		-o : means we emit a number of events, not the files that changed.
	#		-0 : means we separate emitted values by NUL instead of newline
	# xargs
	#		-0 : means we look for NUL separated events
	#		-n 1 : means we run command on every event
	#		-I {} : lets us use {} as a substitute for emitted val (not in use)
	#		reload... : command that gets executed

	# attempt to fire on specific files - worked great for edits but not great for branch switching
	# fswatch -0 carleton.edu | xargs -0 -I {} -n 1 uploadOnSave.sh reallyUpload "${dir}/carleton.edu/" {}
	fswatch -0 carleton.edu | xargs -0 -I {} -n 1 uploadOnSave.sh reallyUpload "${dir}/carleton.edu/" {}
fi
