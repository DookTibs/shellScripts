#!/bin/bash
# jdb -connect com.sun.jdi.SocketAttach:port=9005,hostname=localhost -sourcepath .

# JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_112/" bash -c '/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/bin/catalina.sh start'

# todo - rewrite this to use python or something to be more modular. And then start using this for deployments.

# this will convert to "localdev"  or "localprod" for the Spring profile...
dragonEnv="dev"
numTunnelsNeeded=2

# dragonEnv="prod"
# numTunnelsNeeded=1

openTunnels=`checkTunnels.sh | grep ${dragonEnv}_jumpbox | wc -l`
if [ $openTunnels -ne $numTunnelsNeeded ]; then
	echo "$openTunnels tunnels found running through ${dragonEnv}_jumpbox instead of expected $numTunnelsNeeded"
	echo "Make sure tunnel(s) are configured properly before proceeding (ex: 'tunnel_dragon_${dragonEnv}_start')."
	echo "Exiting without doing anything."
	exit 1
fi



source ~/development/configurations/bash/functions.bash

if [ "cygwin" != "${TOM_OS}" ];then
	echo "Not tested outside of Cygwin; quitting!"
	exit 1
fi

runningTomcatVersion=`echo $TOMCAT_HOME | awk -F "/" '{print $(NF-1)}'`
echo "Running on '$runningTomcatVersion' (Tomcat 8 is port 8088, Tomcat9 is port 8081)"

# TOMCAT_HOME=/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/
logfile=${TOMCAT_HOME}logs/catalina.out

runTomcatCmd() {
	if [ "${1}" == "stop" ] || [ "${1}" == "start" ]; then
		# JPDA are debugger related

		# debugging launch
		# JPDA_ADDRESS="localhost:9005" JPDA_TRANSPORT="dt_socket" CLASSPATH="/cygdrive/c/Program\ Files/Java/jdk1.8.0_112/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=prod,migration -DbaseUrl=http://localhost:8081 -Djava.endorsed.dirs=/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/endorsed -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_112/" bash -c "/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/bin/catalina.sh jpda $1"

		# dev, prod, localdev, localprod

		# standard launch
		AWS_ACCESS_KEY_ID="AKIAJHIK2TXMVBRH5FQA" AWS_SECRET_ACCESS_KEY="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" CLASSPATH="/cygdrive/c/Program\ Files/Java/jdk1.8.0_112/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=local${dragonEnv},tibs -Ddragon.tierType=web -DbaseUrl=http://localhost:8081 -Djava.endorsed.dirs=${TOMCAT_HOME}endorsed -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_112/" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"
	else
		echo "Bad arg to runTomcatCmd..."
	fi
}

startTomcat() {
	echo "Deleting Tomcat logfile..."
	rm -f "$logfile"

	echo "Starting Tomcat"
	runTomcatCmd start
	echo "Waiting for webapp initialization to complete..."
	startLine=`logwatcher.sh $logfile "Server startup in"`
	msToStart=`echo "${startLine}" | awk '{ print $(NF-1) }'`
	prettyTime $msToStart
	echo "Initialization completed in ${_prettyTime}"
	# blinkRed

	# now we take a guess - Tomcat takes at least 2 minutes to start up if 
	# everything went well w/ Dragon. So let's blink greenish if it took awhile. If
	# there was a Spring error during boot, the app will not initialize correctly
	# and Tomcat will come up faster. So if Tomcat starts up faster than that, we know
	# it's an error, and we blink red.
	if [ ${msToStart} -gt 120000 ]; then
		tmux_blink colour28
	else
		tmux_blink red
	fi
}

stopTomcat() {
	if [ -n "${processId}" ]; then
		echo "Stopping running Tomcat process..."
		runTomcatCmd stop
		waitForStoppage
	fi
}

processId=""
# runs and sets global var processId
getProcessId() {
	if [ "cygwin" = ${TOM_OS} ];then
		processId=`procps all | grep $runningTomcatVersion | grep "\-DbaseUrl=.*localhost:8081" | awk '{ print $3 }'`
	fi
}

usage() {
	if [ "${1}" != "" ]; then
		echo "Unsupported command '${1}'"
	else
		echo "No command supplied"
	fi
	echo "Supported commands:"
	echo "'status'	Check if Tomcat is running or not"
	echo "'stop'		Stop Tomcat localhost instance using scripts"
	echo "'kill'		Stop Tomcat localhost instance using shell kill command"
	echo "'start'		Stop Tomcat localhost instance"
	echo "'redeploy'	Builds and deploys DRAGON Online war, bouncing the Tomcat localhost instance"
	echo "'watch'		Tails the Tomcat log file"
}

_prettyTime=""
prettyTime() {
	ms=${1}
	seconds=$(expr ${ms} / 1000)
	minutes=$(expr ${seconds} / 60)
	leftoverSeconds=$(expr ${seconds} % 60)
	leftoverMs=$(expr ${ms} % 1000)
	# _prettyTime="${minutes}:${leftoverSeconds}.${leftoverMs}"
	_prettyTime=`printf "%d:%02d.%d" $minutes $leftoverSeconds $leftoverMs`
}

waitForStoppage() {
	# keep checking til processId is dead
	while [ 1 -eq 1 ]; do
		echo "waiting for tomcat to stop..."
		getProcessId
		if [ -z "${processId}" ]; then
			break
		fi
		sleep 1
	done
	echo "Tomcat stopped!"
}

# get the process id
getProcessId

if [ -z $1 ]; then
	usage
elif [ "${1}" == "stop" ] || [ "${1}" == "status" ] || [ "${1}" == "kill" ]; then
	if [ -n "${processId}" ]; then
		echo "Tomcat is running as pid ${processId}"
		if [ "${1}" == "stop" ]; then
			stopTomcat
		elif [ "${1}" == "kill" ]; then
			echo "Killing..."
			kill ${processId}
		fi
	else
		echo "Tomcat does not appear to be running."
	fi
elif [ "${1}" == "bounce" ]; then
	stopTomcat
	startTomcat
elif [ "${1}" == "start" ]; then
	if [ -n "${processId}" ]; then
		echo "Tomcat is already running as pid ${processId}"
	else
		startTomcat
	fi
elif [ "${1}" == "redeploy" ]; then
	echo "Not rebuilding styles..."
	cd $DRAGON_HOME/src/main/webapp/
	# gulp styles
	# tr -d '\r' < css/main.css > css/tempUnix.css
	# mv css/tempUnix.css css/main.css
	

	#we'll assume the sass build was ok; it's not currently returning an error exit code when compilation error occurred...

	echo "Rebuilding war..."
	cd $DRAGON_HOME

	# get the hash of the current commit in Git; we'll use this to name the war
	currentHash=`git log --pretty=format:'%H' -n 1`
	echo "Commit hash is [$currentHash]...."

	mvn clean package

	if [ $? -ne 0 ]; then
		echo "Error building war; not proceeding."
		exit 1
	fi

	if [ -n "${processId}" ]; then
		stopTomcat
	fi

	echo "Clearing out installed webapp from Tomcat..."
	rm -rf ${TOMCAT_HOME}webapps/ROOT/
	cp target/dragon-0.0.1-SNAPSHOT.war ${TOMCAT_HOME}webapps2

	cp target/dragon-0.0.1-SNAPSHOT.war target/dragon-${currentHash}.war

	# echo "Deleting problematic .ebextensions from worker tier"
	# cp target/dragon-0.0.1-SNAPSHOT.war target/dragon-${currentHash}-web.war
	# cp target/dragon-0.0.1-SNAPSHOT.war target/dragon-${currentHash}-worker.war
	# zip -d target/dragon-${currentHash}-worker.war .ebextensions/increase_request_timeout_eb.config .ebextensions/httpd/

	startTomcat
elif [ "${1}" == "watch" ]; then
	tail -F ${logfile}
else
	usage "${1}"
fi
