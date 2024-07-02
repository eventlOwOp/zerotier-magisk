#!/system/bin/sh

MODDIR=${0%/*}

# load variables
. $MODDIR/vars.sh

log_cli() {
  echo -e "$1" >> $ZTROOT/run/cli.out
}
log() {
  t=`date +"%m-%d %H:%M:%S.%3N"`
  echo -e "[$t][$$][L] $@" >> $DAEMON_LOG
  log_cli "$@"
}
_stop() {
  pid=`pidof zerotier-one`
  if [[ $? -ne 0 ]]; then
    log "zerotier-one not running"
    return
  fi

  kill -9 $pid
  if [[ $? -ne 0 ]]; then
    log "kill zerotier-one failed"
    return
  fi

  log "stopped zerotier-one"
}
_start() {
  if pidof zerotier-one > /dev/null; then
    log "zerotier-one already running"
  else
    __start
    log "started zerotier-one"
  fi
}
_status() {
  # fake systemd lol
  read pid < $ZTROOT/home/zerotier-one.pid

  if pidof zerotier-one > /dev/null; then
    log_cli "\033[32m●\033[0m zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: \033[32mactive (running)\033[0m"
    log_cli "   Main PID: $pid (zerotier-one)"
  else
    log_cli "○ zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: inactive (dead)"
    log_cli "   Main PID: $pid (code=exited)"
  fi
}
_restart() {
  _stop
  __start
  log "started zerotier-one"
}

# ----------------------------------------------
#             call from inotifyd
# ----------------------------------------------

if [[ $# == 2 && "$1" == "w" ]]; then
  read cmd < $2
  rm -f $ZTROOT/run/cli.out

  case "$cmd" in
    "start") _start;;
    "stop") _stop;;
    "restart") _restart;;
    "status") _status;;
    *) log "unknown command $cmd";;
  esac

  if [[ -f "$ZTROOT/run/cli.pid" ]]; then
    read cpid < $ZTROOT/run/cli.pid
    rm -f $ZTROOT/run/cli.pid
    kill -SIGUSR1 $cpid
  fi

  exit 0
fi