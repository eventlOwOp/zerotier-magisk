#!/system/bin/sh

MODDIR=${0%/*}

cd /data/adb/zerotier

# 检测网络是否连接
while ! ping -c 1 -W 1 qq.com; do
    echo "等待网络连接..."
    sleep 5
done

# 当网络连接后，执行脚本
sh ./add_ip_rule.sh
sh ./start.sh
sleep 30
sh ./join.sh
