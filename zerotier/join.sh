export LD_LIBRARY_PATH=/data/adb/zerotier/lib
cd /data/adb/zerotier/
cat /sdcard/Android/zerotier/network_id.txt | xargs ./zerotier-cli -D./home join
