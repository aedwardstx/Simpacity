#!/bin/bash
# zpoller daemon
# description: zpoller daemon
# processname: zpoller

### BEGIN INIT INFO
# Provides:          zpoller
# Required-Start:    mongodb networking 
# Required-Stop:     mongodb networking
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by zpoller.
### END INIT INFO


DAEMON_PATH="/usr/local/lib/node_modules/zpoller"

DAEMON=zpoller

PATH=/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/rvm/bin

NAME=zpoller
DESC="zpoller SNMP poller"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

case "$1" in
start)
        printf "%-50s" "Starting $NAME..."
        cd $DAEMON_PATH
        if [ -f $PIDFILE ]; then
          PID=`cat $PIDFILE`
          if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
            printf "%s\n" "Process dead but pidfile exists"
            rm -f $PIDFILE
            PID=`./bin/zpoller > /dev/null 2>&1 & echo $!`
            #echo "Saving PID" $PID " to " $PIDFILE
            if [ -z $PID ]; then
              printf "%s\n" "Fail"
            else
              echo $PID > $PIDFILE
              printf "%s\n" "Ok"
            fi
          else
            echo "Already Running pid $PID"
          fi
        else
          PID=`./bin/zpoller > /dev/null 2>&1 & echo $!`
          #echo "Saving PID" $PID " to " $PIDFILE
          if [ -z $PID ]; then
            printf "%s\n" "Fail"
          else
            echo $PID > $PIDFILE
            printf "%s\n" "Ok"
          fi
        fi
;;
status)
        printf "%-50s" "Checking $NAME..."
        if [ -f $PIDFILE ]; then
            PID=`cat $PIDFILE`
            if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
                printf "%s\n" "Process dead but pidfile exists"
            else
                echo "Running"
            fi
        else
            printf "%s\n" "Service not running"
        fi
;;
stop)
        printf "%-50s" "Stopping $NAME"
            PID=`cat $PIDFILE`
            cd $DAEMON_PATH
        if [ -f $PIDFILE ]; then
            kill -HUP $PID
            printf "%s\n" "Ok"
            rm -f $PIDFILE
        else
            printf "%s\n" "pidfile not found"
        fi
;;

restart)
    $0 stop
    $0 start
;;

*)
        echo "Usage: $0 {status|start|stop|restart}"
        exit 1
esac
