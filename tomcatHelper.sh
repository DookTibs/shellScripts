#!/bin/bash
# JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_112/" bash -c '/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/bin/catalina.sh start'

if [ "cygwin" != "${TOM_OS}" ];then
	echo "Not tested outside of Cygwin; quitting!"
	exit 1
fi

runTomcatCmd() {
	if [ "${1}" == "stop" ] || [ "${1}" == "start" ]; then
		CLASSPATH="/cygdrive/c/Program\ Files/Java/jdk1.8.0_112/lib/tools.jar" CATALINA_OPTS="-Dspring.profiles.active=dev,migration -DbaseUrl=http://localhost:8080 -Djava.endorsed.dirs=/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/endorsed -XX:+CMSClassUnloadingEnabled -Dfile.encoding=Cp1252" JAVA_HOME="/cygdrive/c/Program Files/Java/jdk1.8.0_112/" bash -c "/cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/bin/catalina.sh $1"
	else
		echo "Bad arg to runTomcatCmd..."
	fi
}

usage() {
	if [ "${1}" != "" ]; then
		echo "Unsupported arg '${1}'"
	else
		echo "No arg supplied"
	fi
	echo "Supported args: 'status', 'stop', 'start', 'watch'"
}

if [ "cygwin" = ${TOM_OS} ];then
	processId=`procps all | grep "apache-tomcat-9.0.0.M15" | grep "\-DbaseUrl=.*localhost:8080" | awk '{ print $3 }'`
fi

if [ -z $1 ]; then
	usage
elif [ "${1}" == "stop" ] || [ "${1}" == "status" ]; then
	if [ -n "${processId}" ]; then
		echo "Tomcat is running as pid ${processId}"
		if [ "${1}" == "stop" ]; then
			runTomcatCmd stop
		fi
	else
		echo "Tomcat does not appear to be running."
	fi
elif [ "${1}" == "start" ]; then
	if [ -n "${processId}" ]; then
		echo "Tomcat is already running as pid ${processId}"
	else
		runTomcatCmd start
	fi
elif [ "${1}" == "redeploy" ]; then
	echo "Not yet implemented; clear out webapps/ROOT/, make sure dragon.war is up to date, etc."
elif [ "${1}" == "watch" ]; then
	tail -f /cygdrive/c/development/tomcat/apache-tomcat-9.0.0.M15/logs/catalina.out
else
	usage "${1}"
fi
