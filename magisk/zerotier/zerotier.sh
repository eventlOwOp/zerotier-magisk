#!/system/bin/sh

ZTROOT=/data/adb/zerotier
PIPE=$ZTROOT/run/pipe

HELP="Usage: zerotier.sh {start|stop|restart|status}"

if [[ ! -f $PIPE ]]; then
    echo "daemon not running"
    exit 1
fi

echo $$ > $ZTROOT/run/cli.pid

on_receive() {
  kill -9 %%
  cat $ZTROOT/run/cli.out
  exit 0
}
run() {
  echo $cmd > $PIPE
}

trap 'on_receive' SIGUSR1
cmd=$1

if [[ $# -eq 1 ]]; then
  case "$cmd" in
    "start") run;;
    "stop") run;;
    "restart") run;;
    "status") run;;
    *) echo "unknown command $cmd";;
  esac
else
  echo $HELP
  exit 1
fi

sleep 20 &
wait

echo "20 seconds time out"
exit 1