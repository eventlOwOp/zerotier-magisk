#!/system/bin/sh

MODDIR=${0%/*}

ZTROOT=/data/adb/zerotier
ZTRUNTIME=$ZTROOT/run
APPROOT=/data/data/com.eventlowop.zerotier_magisk_app/files

pipe=$ZTRUNTIME/pipe
ZTLOG=$ZTRUNTIME/zerotier.log
daemon_log=$ZTRUNTIME/daemon.log

cli_output=$ZTRUNTIME/cli.out
cli_pid=$ZTRUNTIME/cli.pid

log() {
  t=`date +"%m-%d %H:%M:%S.%3N"`
  echo -e "[$t][$$][L] $1" >> $daemon_log
  echo -e "$1" >> $cli_output
}
log_cli() {
  echo -e "$1" >> $cli_output
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

  wait
  log "stopped zerotier-one"
}
__start() {
  $ZTROOT/zerotier-one -d >> $ZTLOG 2>&1 &
}
_start() {
  if pid=`pidof zerotier-one`; then
    log "zerotier-one already running pid $pid"
  else
    __start
    pid=`pidof zerotier-one`
    log "started zerotier-one pid $pid"
  fi
}
_status() {
  # fake systemd lol
  if pid=`pidof zerotier-one`; then
    log_cli "\033[32m●\033[0m zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: \033[32mactive (running)\033[0m"
    log_cli "   Main PID: $pid (zerotier-one)" 
  else
    pid_=`cat $zerotier_root/home/zerotier-one.pid`
    log_cli "○ zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: inactive (dead)"
    log_cli "   Main PID: $pid_ (code=exited)"
  fi
}

cd $ZTROOT
rm -f $ZTRUNTIME
mkfifo $pipe

chmod 666 $pipe $cli_output $cli_pid

ip rule add from all lookup main pref 1
export LD_LIBRARY_PATH=/data/adb/zerotier/lib

if [[ -e /data/data/com.eventlowop.zerotier_magisk_app/files ]]; then
	ln -sf $pipe $APPROOT/pipe
  ln -sf $cli_output $APPROOT/cli.out
  ln -sf $cli_pid $APPROOT/cli.pid
fi

__start

while true
do
  if read cmd < $pipe; then
    case "$cmd" in
      "start") _start;;
      "stop") _stop;;
      "restart") _stop; _start;;
      "status") _status;;
      *) log "unknown command $cmd";;
    esac

    cpid=`cat $cli_pid`
    kill -SIGUSR1 $cpid;
  fi
done
