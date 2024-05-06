#!/bin/sh
pkill -9 zerotier-one
cd /data/adb/zerotier
sleep 1
sh ./start.sh
sleep 1
sh ./join.sh
