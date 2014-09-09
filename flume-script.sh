#!/bin/bash

# home for flume
FLUME_HOME= /home/apps/flume

FLUME_STOP_WAIT_TIME=5

start() {
	nohup $FLUME_HOME/bin/flume-ng agent -n agent -c $FLUME_HOME/conf/$PROJECT -f $FLUME_HOME/conf/$PROJECT/flume-conf.properties --no-reload-conf > $FLUME_HOME/logs/$PROJECT.out 2>&1 &

	RUN=`ps -ef | grep flume/conf/$PROJECT | grep -v 'grep'| wc -l`
	if [ $RUN != 1 ]; then
		echo "flume process is not running"
		exit 1
	fi

	echo "flume is running"
}

stop() {
	PID=`ps -ef | grep flume/conf/$PROJECT | grep -v 'grep' | awk '{print $2}'`
	if [ -n ${PID} ]; then
		kill -TERM ${PID} &>/dev/null
		
		sleep ${FLUME_STOP_WAIT_TIME}

		RUN=`ps -ef | grep flume/conf/$PROJECT | grep -v 'grep'| wc -l`
		if [ $RUN != 0 ]; then
			kill -9 ${PID} &>/dev/null
		fi
	fi

	echo "flume is stopped"
}

restart() {
	stop
	sleep 1
	start
}

if [ `whoami` != "irteam" ]; then
	echo "access denied.(irteam)"
	exit 1
fi

if [ -z "$2" ]; then
	echo "need config folder name. ex) flume/conf/(project)"
	exit 1
fi

PROJECT=$2

case $1 in
	start) start;;
	stop) stop;;
	restart) restart;;
	*) echo "usage: $0 start|stop|restart";;
esac
exit 0
