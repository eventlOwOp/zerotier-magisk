#!/system/bin/sh
pipe=/data/adb/zerotier/run/pipe
if [[ ! -p $pipe ]]; then
    echo "daemon not running"
    exit 1
fi

if [[ "$1" ]]; then
  echo "$1" > $pipe
else
  echo "Usage: zerotier.sh {start|stop|restart|join|leave}"
fi
