#!/bin/bash
COOKIE_FILE=~/development/curlStorage/CURL_COOKIE_FILE.txt
OUTPUT_FILE=~/development/curlStorage/curlResults.html

BASE_CMD="curl -b ${COOKIE_FILE} -c ${COOKIE_FILE}"
QUIET_CMD="${BASE_CMD} -s -o ${OUTPUT_FILE}"

forceLogin=0
username=""
password=""
url=""

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
	fi
	# echo "$var"
	let looper=$looper+1
done

if [ ! -f ${COOKIE_FILE} ] || [ $forceLogin -eq 1 ]; then
	if [ "${username}" = "" ] || [ "${password}" = "" ]; then
		echo "username/password not supplied"
		exit 1
	else
		# hit the login page to set the test cookie
		${QUIET_CMD} ###REDACTED###

		# now hit the login page with real data
		${QUIET_CMD} -d "username=${username}&password=${password}" ###REDACTED###
	fi
fi

# did login work?
grep -q "REASON_SESSION_EXISTS" ${COOKIE_FILE}

if [ $? -eq 0 ]; then
	if [ "${url}" = "" ]; then
		echo "specify a url with -u <URL>, ex: 'reasonApiTester.sh -u /rest/ems/cams/20140911/20140918'"
	else
		${BASE_CMD} -s "###REDACTED###{url}" | python -m json.tool
	fi
else
	echo "invalid login credentials; deleting ${COOKIE_FILE}"
	rm $COOKIE_FILE
fi
