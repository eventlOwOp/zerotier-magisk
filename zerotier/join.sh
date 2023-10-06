export LD_LIBRARY_PATH=/data/adb/zerotier
cat ./network | xargs ./zerotier-cli -D./home join
