#!/bin/bash
COOKIE_FILE=~/development/curlStorage/MOODLE_COOKIE_FILE.txt
OUTPUT_FILE=~/development/curlStorage/curlResults.html

BASE_CMD="curl -b ${COOKIE_FILE} -c ${COOKIE_FILE}"
# BASE_CMD="curl -c ${COOKIE_FILE}"
QUIET_CMD="${BASE_CMD} -s -o ${OUTPUT_FILE}"

forceLogin=0
username=""
password=""
url=""
verbose=0

looper=0
nextIndex=0
for var in "$@"
do
	let nextIndex=$looper+2
	# echo "[${looper}] = [${var}]"
	if [ "${var}" = "-f" ]; then
		forceLogin=1
	elif [ "${var}" = "-l" ]; then
		username="${@:$nextIndex:1}"
	elif [ "${var}" = "-p" ]; then
		password="${@:$nextIndex:1}"
	elif [ "${var}" = "-u" ]; then
		url="${@:$nextIndex:1}"
	elif [ "${var}" = "-v" ]; then
		let verbose=1
	fi
	# echo "$var"
	let looper=$looper+1
done

if [ ! -f ${COOKIE_FILE} ] || [ $forceLogin -eq 1 ]; then
	if [ "${username}" = "" ] || [ "${password}" = "" ]; then
		echo "username/password not supplied"
		exit 1
	else
		# now hit the login page with real data
		${QUIET_CMD} -d "username=${username}&password=${password}" https://moodle.carleton.edu/login/index.php
	fi
fi

# did login work?
grep -q "MOODLEID1_" ${COOKIE_FILE}

if [ $? -eq 0 ]; then
	${BASE_CMD} "https://moodle.carleton.edu/report/progress/index.php?course=19650&format=csv" > ~/development/curlStorage/sample.csv
else
	echo "invalid login credentials; deleting ${COOKIE_FILE}"
	rm $COOKIE_FILE
fi
