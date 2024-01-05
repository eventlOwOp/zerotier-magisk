#!/system/bin/sh

MODDIR=${0%/*}

cd /data/adb/zerotier

sh ./add_ip_rule.sh
sh ./start.sh
sh ./join.sh
