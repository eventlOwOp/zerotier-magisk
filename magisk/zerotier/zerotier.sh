#!/system/bin/sh
pipe=/data/adb/zerotier/run/pipe

cli_output=/data/adb/zerotier/run/cli.out
cli_pid=/data/adb/zerotier/run/cli.pid

help_text="Usage: zerotier.sh {start|stop|restart|status}"

if [[ ! -p $pipe ]]; then
    echo "daemon not running"
    exit 1
fi

rm -f $cli_output
echo $$ > $cli_pid

on_receive() {
  cat $cli_output
  exit 0
}
run() {
  echo $1 > $pipe
}

trap 'on_receive' SIGUSR1

if [[ "$1" ]]; then
  if [[ "$2" ]]; then
    echo $help_text
    exit 1
  fi

  case "$1" in
    "start") run $1;;
    "stop") run $1;;
    "restart") run $1;;
    "status") run $1;;
    *)
      echo "unknown command $1";;
  esac
else
  echo $help_text
  exit 1
fi

sleep 20 &
wait $!
echo "time out"
exit 1