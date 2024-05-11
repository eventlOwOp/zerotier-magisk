#!/system/bin/sh

MODDIR=${0%/*}

pipe=/data/adb/zerotier/run/pipe
zerotier_log=/data/adb/zerotier/run/zerotier.log
daemon_log=/data/adb/zerotier/run/daemon.log
network_id_path=/sdcard/Android/zerotier/network_id.txt
pid=-1

log() {
  t=`date +"%m-%d %H:%M:%S.%3N"`
  echo "[$t][$$][L] $1" >> $daemon_log
}
_stop() {
  pid=$(pidof zerotier-one)
  if [ $? -ne 0 ]; then
    log "zerotier-one not running"
    return 1
  fi

  kill -9 $pid
  ret=$?

  rm -rf ./run/pid

  if [ $ret -eq 0 ]; then
    log "stopped zerotier-one"
    return 0
  else
    log "kill zerotier-one failed"
  fi
  
  return 1
}

_join() {
  nid=$(cat $network_id_path)

  ./zerotier-cli -D./home join $nid > $zerotier_log 2>&1

  if [ $? -ne 0 ]; then
    log "join network failed"
    return 1
  else
    log "joined $nid"
  fi

  return 0
}

_leave() {
  nid=$(cat $network_id_path)

  ./zerotier-cli -D./home leave $nid > $zerotier_log 2>&1

  if [ $? -ne 0 ]; then
    log "leave network failed"
    return 1
  else
    log "left $nid"
  fi

  return 0
}
__start() {
  nohup ./zerotier-one -d home > $zerotier_log 2>&1 &

  sleep 1

  pid=$(pidof zerotier-one)

  echo $pid > ./run/pid
}
_start() {
  if pid=$(pidof zerotier-one); then
    log "zerotier-one already running pid $pid"
  else
    __start
    log "started zerotier-one pid $pid"
  fi
  
  return 0
}

cd /data/adb/zerotier
rm -f $daemon_log
ip rule add from all lookup main pref 1
export LD_LIBRARY_PATH=/data/adb/zerotier/lib

__start
sleep 1
_join

rm -f $pipe
mkfifo $pipe

while true
do
  if read line < $pipe; then
    log "received commad $line"
    case "$line" in
      "quit")
        log "stopped"
        break;;
      "start") _start;;
      "stop") _stop;;
      "restart")
        _stop
        sleep 1
        _start;;
      "join") _join;;
      "leave") _leave;;
      *)
        log "unknown command $line";;
    esac
  fi
done
