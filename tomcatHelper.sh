#!/bin/bash
# jdb -connect com.sun.jdi.SocketAttach:port=9005,hostname=localhost -sourcepath .

# JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_112/" bash -c '/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/bin/catalina.sh start'

# todo - rewrite this to use python or something to be more modular. And then start using this for deployments.

# not needed anymore; now we get things like the AWS secrets from environment variables...
# source sensitiveData.sh

# this will convert to "localdev"  or "localprod" for the Spring profile...

# default value
# targetEnv="prod"
# targetEnv="dev"
# targetEnv="prod"
# targetEnv="dev2021"
# targetEnv="prod2021"
targetEnv="sandbox"

if [ "${2}" != "" ]; then
	targetEnv="${2}"
fi

if [ "${targetEnv}" == "dev2021" ]; then
	dragonEnv="dev"
	tunnelGrepper="2432"
elif [ "${targetEnv}" == "oldprod" ]; then
	dragonEnv="oldprod"
	tunnelGrepper="9432"
elif [ "${targetEnv}" == "prod2021" ]; then
	dragonEnv="prod"
	tunnelGrepper="1432"
elif [ "${targetEnv}" == "sandbox" ]; then
	dragonEnv="sandbox"
	tunnelGrepper="8432"
elif [ "${targetEnv}" == "dev" ]; then
	dragonEnv="dev"
	tunnelGrepper="3432"
elif [ "${targetEnv}" == "prod" ]; then
	dragonEnv="prod"
	tunnelGrepper="4432"
else
	echo "invalid environment"
	exit 1
fi

dynamic_key_env_lookup="LITSTREAM_APP_SDK_USER_ACCESS_KEY_ID_${targetEnv}"
dynamic_secret_env_lookup="LITSTREAM_APP_SDK_USER_SECRET_ACCESS_KEY_${targetEnv}"

# note the exclamation point; I want to grab something from an environment variable,
# but it's a dynamic name based on the environment passed into this script
# neat trick, learned in Feb 2022, never needed this before!
# https://stackoverflow.com/questions/9714902/how-to-use-a-variables-value-as-another-variables-name-in-bash
aws_access_key_id="${!dynamic_key_env_lookup}"
aws_secret_access_key="${!dynamic_secret_env_lookup}"
echo "for '${targetEnv}', gonna use [${aws_access_key_id}] and [${aws_secret_access_key}] (defined in sensitive_data.sh which should never get checked in..."




# see https://stackoverflow.com/questions/15555838/how-to-pass-tomcat-port-number-on-command-line
tomcatHttpPort=8081
if [ ! -z "${3}" ]; then
	tomcatHttpPort=${3}
fi
# tomcatShutdownPort=$(($tomcatHttpPort + 10))

openTunnels=`checkTunnels.sh | grep "$tunnelGrepper:.*_jumpbox" | wc -l`
if [ $openTunnels -ne 1 ]; then
	echo "$openTunnels tunnels found running for dragon env '$dragonEnv'."

	echo "Make sure tunnel(s) are configured properly before proceeding. (probably tunnel_dragon_${dragonEnv}_start)"
	echo "Exiting without doing anything."
	exit 1
fi

actualDragonEnv="not_set"
actualDragonEnv="local${dragonEnv}"


source ~/development/configurations/bash/functions.bash

runningTomcatVersion=`echo $TOMCAT_HOME | awk -F "/" '{print $(NF-1)}'`
echo "#################"
echo "# env == $dragonEnv"
echo "#################"
# echo "Running on '$runningTomcatVersion' (Tomcat 8 is port 8088, Tomcat9 is port 8081)"
echo "Running on '$runningTomcatVersion' (port $tomcatHttpPort)"

# TOMCAT_HOME=/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/
logfile=${TOMCAT_HOME}logs/catalina.out

runTomcatCmd() {
	if [ "${1}" == "stop" ] || [ "${1}" == "start" ]; then
		# JPDA are debugger related

		# debugging launch
		# JPDA_ADDRESS="localhost:9005" JPDA_TRANSPORT="dt_socket" CLASSPATH="/cygdrive/c/Program\ Files/Java/jdk1.8.0_112/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=prod,migration -DbaseUrl=http://localhost:8081 -Djava.endorsed.dirs=/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/endorsed -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_112/" bash -c "/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/bin/catalina.sh jpda $1"

		# dev, prod, localdev, localprod

		# standard launch
		# AWS_ACCESS_KEY_ID="${S3_USER_AWS_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${S3_USER_AWS_SECRET_ACCESS_KEY}" CLASSPATH="/cygdrive/c/Program\ Files/Java/jdk1.8.0_112/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=${actualDragonEnv},tibs -Ddragon.tierType=web -DbaseUrl=http://localhost:8081 -Djava.endorsed.dirs=${TOMCAT_HOME}endorsed -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_112/" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"
		# AWS_ACCESS_KEY_ID="${S3_USER_AWS_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${S3_USER_AWS_SECRET_ACCESS_KEY}" CLASSPATH="/cygdrive/c/Program\ Files/Java/jdk1.8.0_161/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=${actualDragonEnv},tibs -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Djava.endorsed.dirs=${TOMCAT_HOME}endorsed -Dport.http=${tomcatHttpPort} -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_161/" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"

		if [ "no" == "yes" ]; then
			if [ "${DRAGON_11_UPGRADE}" == "yes" ]; then
				echo "JAVA 11 WORK USING ${TOMCAT_HOME}!!!"
				# testing for JDK 11 / Tomcat 8.5 support - also had to remove some things like endorsed.dirs, CLASSPATH, etc.
				JAVA_TO_USE="/Library/Java/JavaVirtualMachines/amazon-corretto-11.jdk/Contents/Home/"
				# JAVA_TO_USE="/Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home/"
				AWS_ACCESS_KEY_ID="${S3_USER_AWS_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${S3_USER_AWS_SECRET_ACCESS_KEY}" CATALINA_OPTS="-Dspring.profiles.active=${actualDragonEnv},tibs,xmigration -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Dport.http=${tomcatHttpPort} -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="${JAVA_TO_USE}" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"
				# maybe set JAVA_HOME like this?
				# JAVA_HOME="$HOME/.jenv/versions/`jenv version-name`
			else
				echo "LAUNCHING STANDARD"
				# current command as of 20180530
				AWS_ACCESS_KEY_ID="${S3_USER_AWS_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${S3_USER_AWS_SECRET_ACCESS_KEY}" CLASSPATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=${actualDragonEnv},tibs,xmigration -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Djava.endorsed.dirs=${TOMCAT_HOME}endorsed -Dport.http=${tomcatHttpPort} -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"
			fi
		fi


		# trying to add jvisualvm support
		# AWS_ACCESS_KEY_ID="${S3_USER_AWS_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${S3_USER_AWS_SECRET_ACCESS_KEY}" CLASSPATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=${actualDragonEnv},tibs,xmigration -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Djava.endorsed.dirs=${TOMCAT_HOME}endorsed -Dport.http=${tomcatHttpPort} -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=9090 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=localhost -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"

		# current command as of 20180530
		# AWS_ACCESS_KEY_ID="${S3_USER_AWS_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${S3_USER_AWS_SECRET_ACCESS_KEY}" CLASSPATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=${actualDragonEnv},tibs,xmigration -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Djava.endorsed.dirs=${TOMCAT_HOME}endorsed -Dport.http=${tomcatHttpPort} -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"

		# current command as of 20220216
		# AWS_ACCESS_KEY_ID="${aws_access_key_id}" AWS_SECRET_ACCESS_KEY="${aws_secret_access_key}" CATALINA_OPTS="-Daws_profile_for_sdk=use_this_ptofile -Dspring.profiles.active=${actualDragonEnv} -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Dport.http=${tomcatHttpPort} -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"

		# current command as of 20220725
		# maintenanceModeSnippet="-Dlitstream_maintenance_descriptor=2022-12-09_1200:'explanation goes here'"
		maintenanceModeSnippet="-Dlitstream_maintenance_descriptor="
		# maintenanceModeSnippet="-Dlitstream_maintenance_descriptor=2023-02-10_1700"
		if [ "${DEBUG_LITSTREAM}" == "yes" ] && [ "${1}" == "start" ]; then
			echo "(debug ${1}; unset environment variable DEBUG_LITSTREAM=yes if you want JPDA debugging turned off)"
			JPDA_ADDRESS="localhost:9005" JPDA_TRANSPORT="dt_socket" AWS_ACCESS_KEY_ID="${aws_access_key_id}" AWS_SECRET_ACCESS_KEY="${aws_secret_access_key}" CATALINA_OPTS="-Daws_profile_for_sdk=use_this_ptofile -Dspring.profiles.active=${actualDragonEnv},override:tfeiler ${maintenanceModeSnippet} -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Dport.http=${tomcatHttpPort} -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252 -DtosVersion=20220329" bash -c "${TOMCAT_HOME}bin/catalina.sh jpda start"
		else
			echo "(normal ${1}; set environment variable DEBUG_LITSTREAM=yes if you want JPDA debugging turned on)"
			AWS_ACCESS_KEY_ID="${aws_access_key_id}" AWS_SECRET_ACCESS_KEY="${aws_secret_access_key}" CATALINA_OPTS="-Daws_profile_for_sdk=use_this_ptofile -Dspring.profiles.active=${actualDragonEnv},override:tfeiler ${maintenanceModeSnippet} -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Dport.http=${tomcatHttpPort} -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252 -DtosVersion=20220329" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"
		fi

		# TRYING WITHOUT KEYS IN ENVIRONMENT
		# CATALINA_OPTS="-Daws_profile_source_for_sdk=aws_credentials_${targetEnv} -Dspring.profiles.active=${actualDragonEnv} -Ddragon.tierType=web -DbaseUrl=http://localhost:${tomcatHttpPort} -Dport.http=${tomcatHttpPort} -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" bash -c "${TOMCAT_HOME}bin/catalina.sh $1"
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

	# now we take a guess - Tomcat takes at least 45 seconds to start up if 
	# everything went well w/ Dragon. So let's blink greenish if it took awhile. If
	# there was a Spring error during boot, the app will not initialize correctly
	# and Tomcat will come up faster. So if Tomcat starts up faster than that, we know
	# it's an error, and we blink red.
	if [ ${msToStart} -gt 45000 ]; then
		tmux_blink colour28
	else
		tmux_blink red
	fi
}

stopTomcat() {
	if [ -n "${processId}" ]; then
		echo "Stopping running Tomcat process (port ${tomcatShutdownPort})..."
		runTomcatCmd stop
		waitForStoppage
	fi
}

processId=""
# runs and sets global var processId
getProcessId() {
	if [ "cygwin" = ${TOM_OS} ];then
		processId=`procps all | grep $runningTomcatVersion | grep "\-DbaseUrl=.*localhost:${tomcatHttpPort}" | awk '{ print $3 }'`
		# echo "got process id [$processId] from [$runningTomcatVersion]/[$tomcatHttpPort]"
	else
		# OSX
		processId=`ps -eax | grep $runningTomcatVersion | grep "\-DbaseUrl=.*localhost:${tomcatHttpPort}" | awk '{ print $1 }'`
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
	# rm $DRAGON_HOME/last_build_attempt.log
	# mvn -X clean package > $DRAGON_HOME/last_build_attempt.log

	if [ $? -ne 0 ]; then
		echo "Error building war; not proceeding."
		exit 1
	fi

	if [ -n "${processId}" ]; then
		stopTomcat
	fi

	echo "Clearing out installed webapp from Tomcat..."
	rm -rf ${TOMCAT_HOME}webapps/ROOT/

	if [ "xhotswap" == "hotswap" ]; then
		echo "HOT SWAPPING!"
		# make a temp dir...
		cd target
		mkdir hotswap
		cd hotswap

		# unzip the war
		cp ../dragon-0.0.1-SNAPSHOT.war .
		unzip dragon-0.0.1-SNAPSHOT.war
		rm dragon-0.0.1-SNAPSHOT.war

		# replace some jars...
		cp ~/Downloads/poi-src-5.2.2-20220312/build/dist/maven/poi-ooxml/poi-ooxml-5.2.2.jar ./WEB-INF/lib/
		cp ~/Downloads/poi-src-5.2.2-20220312/build/dist/maven/poi-ooxml-lite/poi-ooxml-lite-5.2.2.jar ./WEB-INF/lib/
		cp ~/Downloads/poi-src-5.2.2-20220312/build/dist/maven/poi/poi-5.2.2.jar ./WEB-INF/lib/
		cp ~/Downloads/poi-src-5.2.2-20220312/build/dist/maven/poi-scratchpad/poi-scratchpad-5.2.2.jar ./WEB-INF/lib/

		# re-zip it up...
		zip -r ./hotswapped.zip *

		mv hotswapped.zip ../hotswapped.war
		cd ../..
		cp target/hotswapped.war ${TOMCAT_HOME}webapps2/dragon-0.0.1-SNAPSHOT.war
	else
		cp target/dragon-0.0.1-SNAPSHOT.war ${TOMCAT_HOME}webapps2
	fi


	cp target/dragon-0.0.1-SNAPSHOT.war target/dragon-${currentHash}.war

	# echo "Deleting problematic .ebextensions from worker tier"
	# cp target/dragon-0.0.1-SNAPSHOT.war target/dragon-${currentHash}-web.war
	# cp target/dragon-0.0.1-SNAPSHOT.war target/dragon-${currentHash}-worker.war
	# zip -d target/dragon-${currentHash}-worker.war .ebextensions/increase_request_timeout_eb.config .ebextensions/httpd/

	startTomcat
elif [ "${1}" == "watch" ]; then
	tail -F ${logfile}
	# rainbow --red=EANDK tail -F ${logfile}
else
	usage "${1}"
fi
