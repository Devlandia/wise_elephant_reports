#!/bin/bash

### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       Enable service provided by daemon.
### END INIT INFO

APP_ROOT=$(dirname $(readlink -f "${0}"))
APP_ROOT="${APP_ROOT}/../"
UNICORN_CONFIG="${APP_ROOT}unicorn.rb"
PID="${APP_ROOT}/tmp/pids/unicorn.pid"

KILL=$(which kill)
UNICORN=$(which unicorn)

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

case "$1" in
  start)
    echo "Starting unicorn..."

    $UNICORN -c $UNICORN_CONFIG -E development -D -l 0.0.0.0:3000
    ;;
  stop)
    sig QUIT && exit 0
    echo >&2 "Not running"
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  status)
    ;;
  *)
   echo "Usage: $0 {start|stop|restart|status}"
    ;;
esac
