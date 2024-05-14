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
  kill -9 %%
  cat $cli_output
  exit 0
}
run() {
  echo $cmd > $pipe
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
  echo $help_text
  exit 1
fi

sleep 20 &
wait

echo "20 seconds time out"
exit 1