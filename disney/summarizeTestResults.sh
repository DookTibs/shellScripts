#! /bin/bash

# simple script that looks at the very last line of a karma testrunner output file
# and prints out a simple message indicating if a test failed. suitable for placing
# into a small pane of a tmux session
#
# to use this make sure you redirect karma/jasmine output to appropriate files

source colorizer.sh

KARMA_OUTPUT_FILE="/tmp/karmaOutputTemp"
JASMINE_OUTPUT_FILE="/tmp/jasmineOutputTemp"

STATUS_OK="${txtGreen}ok${txtReset}"
STATUS_FAILED="${txtRed}failed${txtReset}"
STATUS_UNKNOWN="..."

echo ""
while true; do
	###### KARMA - CLIENT ######
	karmaOutput=$(tail -n 1 ${KARMA_OUTPUT_FILE})

	echo "${karmaOutput}" | grep -q "Executed.*SUCCESS"
	karmaSuccessRun=$?

	echo "${karmaOutput}" | grep -q "Executed.*FAILED"
	karmaFailedRun=$?

	karmaStatus="${STATUS_UNKNOWN}"
	if [ ${karmaSuccessRun} -eq 0 ]; then
		karmaStatus="${STATUS_OK}"
	elif [ ${karmaFailedRun} -eq 0 ]; then
		karmaStatus="${STATUS_FAILED}"
	fi

	# echo "client test [${karmaStatus}]"
	# echo "-----"


	###### JASMINE - SERVER ######
	jasmineOutput=$(tail -n 3 ${JASMINE_OUTPUT_FILE})
	# echo "jasmine output=[${jasmineOutput}]"

	echo "${jasmineOutput}" | grep -q "0 failures, 0 skipped"
	jasmineSuccessRun=$?

	echo "${jasmineOutput}" | grep -q ".*assertion.*failure.*skipped"
	jasmineFailedRun=$?

	jasmineStatus="${STATUS_UNKNOWN}"
	if [ ${jasmineSuccessRun} -eq 0 ]; then
		jasmineStatus="${STATUS_OK}"
	elif [ ${jasmineFailedRun} -eq 0 ]; then
		jasmineStatus="${STATUS_FAILED}"
	fi


	##### SHOW CURRENT GIT BRANCH
	cd $ASSET_PIPELINE
	# currentBranch=$(git rev-parse --abbrev-ref HEAD)
	currentBranch=$(git symbolic-ref --short HEAD)

	if [ "${jasmineStatus}" = "${STATUS_OK}" ] && [ "${karmaStatus}" = "${STATUS_OK}" ]; then
		# output a line in green
		echo -ne "   Branch [${txtPurple}${currentBranch}${txtReset}] : ${txtGreen}Unit Test Results...server=[ok], client=[ok]${txtReset}                    \r"
	else
		# show some red!!!
		echo -ne "   Branch [${txtPurple}${currentBranch}${txtReset}] : ${txtRed}Unit Test Results${txtReset}...server=[${jasmineStatus}], client=[${karmaStatus}]${txtReset}                    \r"
	fi

	sleep 2
done
