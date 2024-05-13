#!/system/bin/sh

MODDIR=${0%/*}

zerotier_root=/data/adb/zerotier

pipe=/data/adb/zerotier/run/pipe
zerotier_log=/data/adb/zerotier/run/zerotier.log
daemon_log=/data/adb/zerotier/run/daemon.log
network_id_path=/sdcard/Android/zerotier/network_id.txt
pid=-1

cli_output=/data/adb/zerotier/run/cli.out
cli_pid=/data/adb/zerotier/run/cli.pid

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
  if [ $? -ne 0 ]; then
    log "zerotier-one not running"
    return 1
  fi

  kill -9 $pid
  ret=$?

  if [ $ret -eq 0 ]; then
    log "stopped zerotier-one"
    return 0
  else
    log "kill zerotier-one failed"
  fi
  
  return 1
}

__start() {
  nohup ./zerotier-one -d >> $zerotier_log 2>&1 &

  sleep 1

  pid=`pidof zerotier-one`
}
_start() {
  if pid=`pidof zerotier-one`; then
    log "zerotier-one already running pid $pid"
  else
    __start
    log "started zerotier-one pid $pid"
  fi
  
  return 0
}
_status() {
  # fake systemd lol
  if pid=`pidof zerotier-one`; then
    log_cli "\033[32m●\033[0m zerotier-one.service - ZeroTier One - Global Area Networking"
    log_cli "     Active: \033[32mactive (running)\033[0m"
    log_cli "   Main PID: $pid (zerotier-one)" 
  else
    pid_=`cat $zerotier_root/home/zerotier-one.pid`
    log_cli "○ zerotier-one is stopped"
    log_cli "     Active: inactive (dead)"
    log_cli "   Main PID: $pid_ (code=exited)"
  fi
}

# _join() {
#   nid=$(cat $network_id_path)

#   ./zerotier-cli join $nid >> $zerotier_log 2>&1

#   if [ $? -ne 0 ]; then
#     log "join network failed"
#     return 1
#   else
#     log "joined $nid"
#   fi

#   return 0
# }

# _leave() {
#   nid=$(cat $network_id_path)

#   ./zerotier-cli leave $nid >> $zerotier_log 2>&1

#   if [ $? -ne 0 ]; then
#     log "leave network failed"
#     return 1
#   else
#     log "left $nid"
#   fi

#   return 0
# }

cd /data/adb/zerotier
rm -f ./run/*
mkfifo $pipe

ip rule add from all lookup main pref 1
export LD_LIBRARY_PATH=/data/adb/zerotier/lib

__start
(sleep 20 && _join) &

while true
do
  if read cmd < $pipe; then
    case "$cmd" in
      "start") _start;;
      "stop") _stop;;
      "restart")
        _stop
        sleep 1
        _start;;
      "status") _status;;
      *)
        log "unknown command $cmd";;
    esac

    cpid=`cat $cli_pid`
    kill -SIGUSR1 $cpid;
  fi
done
