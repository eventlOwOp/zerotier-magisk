# variables

ZTROOT=/data/adb/zerotier
APPROOT=/data/data/com.eventlowop.zerotier_magisk_app/app_flutter

ZT_LOG=$ZTROOT/run/zerotier.log
DAEMON_LOG=$ZTROOT/run/daemon.log

PIPE_CLI=$ZTROOT/run/pipe
PIPE_APP=$APPROOT/run/pipe

BB=/data/adb/magisk/busybox

# LD_LIBRARY_PATH for NDK
export LD_LIBRARY_PATH=/system/lib64:/data/adb/zerotier/lib

__start() {
    nohup $ZTROOT/zerotier-one -d &>> $ZT_LOG &
}