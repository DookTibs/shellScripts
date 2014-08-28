#! /bin/bash

# script that checks a list of asset url's for Club Penguin to see if they exist or not on the CDN

USAGE="Usage: ./prober.sh <file_containing_urls_to_test> <file_for_results> (retry_attempt_max, default=1)"

# ???
# BASE_CDN_URL="http://media1.clubpenguin.com/mobile"

# STAGE
# BASE_CDN_URL="http://stage.media8.clubpenguin.com/mobile"
BASE_CDN_URL="http://media8.clubpenguin.com/mobile"

# CURL_CMD="curl --head --header \"Pragma:akamai-x-cache-on,akamai-x-cache-remote-on,akamai-x-check-cacheable,akamai-x-get-cache-key,akamai-x-get-extracted-values,akamai-x-get-nonces,akamai-x-get-ssl-client-session-id,akamai-x-get-true-cache-key,akamai-x-serial-no\" --write-out %{http_code} --silent --output /dev/null"


CURL_CMD="curl --head --header Pragma:akamai-x-cache-on,akamai-x-cache-remote-on,akamai-x-check-cacheable,akamai-x-get-cache-key,akamai-x-get-extracted-values,akamai-x-get-nonces,akamai-x-get-ssl-client-session-id,akamai-x-get-true-cache-key,akamai-x-serial-no --silent"
HTTP_OK=200

CDN_HEADER="X-Cache"
# CDN_HEADER="ETag"

if [ -z "$3" ]; then
	RETRY_ATTEMPTS_MAX=1
else
	RETRY_ATTEMPTS_MAX=${3}
fi
RESULTS_HEADER="Unable to retrieve the following files from the CDN, with http status codes (made $RETRY_ATTEMPTS_MAX attempts):"

# did user supply necessary arguments to script?
if [ -z "$1" ] || [ -z "$2" ]; then
	echo "${USAGE}"
	exit 1
fi

# does input file exist?
if [ -e "$1" ]
then
	if [ -e "$2" ]; then
		echo "result file already exists; exiting without doing any work"
		# exit 1
	fi

	# set up the output file
	echo ${RESULTS_HEADER} > ${2}
	echo "START TIME: $(date)" >> ${2}

	# find out how many lines we need to process so we can see how long things are taking to run
	wcData=$(wc -l ${1})
	wcTokens=( $wcData )
	linesInDataFile=${wcTokens[0]}

	echo "Reading $linesInDataFile url's to test from [${1}]..."

	# start looping...
	urlCounter=1
	while read loopUrl; do
		preservedUrl=${loopUrl}

		# if the normal dot slash lead pattern is there, make it a real url
		if [ ${loopUrl:0:2} = "./" ]
		then
			loopUrl="${BASE_CDN_URL}${loopUrl:1}"
		fi

		echo ">>> checking [$urlCounter]/[$linesInDataFile]: [${loopUrl}]..."

		cmdToRun="${CURL_CMD} ${loopUrl}"

		# echo "cmd=[$cmdToRun]"
		# echo ""

		timesAttempted=1
		fileIsOk=0

		while [ $timesAttempted -le $RETRY_ATTEMPTS_MAX ]; do
			if [ $timesAttempted -gt 1 ]; then
				echo "attempt [$timesAttempted]/[$RETRY_ATTEMPTS_MAX]; server reply for last attempt was [$serverResponse]..."
			fi

			# serverResponse=$($cmdToRun)
			serverResponse=`$cmdToRun`

			echo "server reply [${serverResponse}]"
			let fileIsOk=1

			# alternate approach - look for a particular header
			if [ 5 -lt 6 ]; then
				headerData=( $serverResponse )
				numElements=${#headerData[@]}
				headerLooper=0
				cacheVal=""
				while [ $headerLooper -lt ${numElements} ]; do
					currHeaderData=${headerData[$headerLooper]}
					# echo "$headerLooper -> ${currHeaderData}"

					if [ "${currHeaderData}" = "$CDN_HEADER:" ]; then
						let headerLooper=$headerLooper+1
						cacheVal=${headerData[$headerLooper]}
						break;
					fi
					let headerLooper=$headerLooper+1
				done

				if [ "${cacheVal}" != "" ]; then
					echo "CACHE -> [${cacheVal}]"
				else
					echo "no data to extract..."
				fi
			else
				if [[ $serverResponse =~ ETag:."(.*)" ]]; then
					echo "!!! ETAG !!! --> [${BASH_REMATCH[1]}]"
				fi

			fi

			# for headerData in $serverResponse; do
				# echo "header line [${headerLine}]"
			# done
			# if [[ $serverResponse =~ ETag:."(.*)" ]]; then
				# echo "!!! ETAG !!! --> [${BASH_REMATCH[1]}]"
			# fi



			# if [ $serverResponse -eq $HTTP_OK ]; then
				# let fileIsOk=1
				# let timesAttempted=$RETRY_ATTEMPTS_MAX;
			# # else
				# # echo "server reply [${serverResponse}]"
				# # no guarantee this exists on other systems, and do we even care?
				# # sleep 0.5
			# fi

			let timesAttempted=$timesAttempted+1;
		done

		# echo "result for ${loopUrl}: [$fileIsOk]!"

		# if file wasn't found, tack it onto the results url
		if [ $fileIsOk -eq 0 ]; then
			errorFile="tempError_${serverResponse}.tmp"
			echo "    ${preservedUrl}" >> $errorFile

			# echo "($serverResponse) ${preservedUrl}" >> ${2}
		fi

		echo ""

		let urlCounter=$urlCounter+1
	done < ${1}

	# now we're done; all the problematic url's are in files like tempError_301.tmp, etc. aggregate them into
	# one result file, and then clean up after ourselves...
	#

	# slash in front of ls gets us the unaliased version in case there is one; all we want are the filenames
	tempErrorFiles=$(\ls tempError*.tmp)

	for tempErrorFile in $tempErrorFiles; do
		# regex to capture the error code for this file
		[[ $tempErrorFile =~ tempError_(.*)\.tmp ]]

		# BASH_REMATCH lets us play back the captured sequences
		echo "${BASH_REMATCH[1]}" >> ${2}
		cat ${tempErrorFile} >> ${2}

		# and remove the temp file when we're done
		rm ${tempErrorFile}
	done
	echo "END TIME: $(date)" >> ${2}

	echo "-=[ RESULTS ]=-"
	cat ${2}
else
	echo "Input file does not exist!"
	exit 1
fi
