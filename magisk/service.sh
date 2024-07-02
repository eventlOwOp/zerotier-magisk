#!/system/bin/sh

MODDIR=${0%/*}

# load variables
. $MODDIR/vars.sh

# wait_until_login from yc9559/uperf at uperf/magisk/script/libcommon.sh
wait_until_login() {
    # in case of /data encryption is disabled
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done

    # we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
    local test_file="/sdcard/Android/.PERMISSION_TEST"
    true >"$test_file"
    while [ ! -f "$test_file" ]; do
        true >"$test_file"
        sleep 1
    done
    rm "$test_file"
}

# ----------------------------------------------
#             clean before start
# ----------------------------------------------

rm -rf   $ZTROOT/run
mkdir -p $ZTROOT/run

# ----------------------------------------------
#             start zerotier
# ----------------------------------------------

# add main route table to lookup rules
ip rule add from all lookup main pref 1
ip -6 rule add from all lookup main pref 1

# LD_LIBRARY_PATH for NDK
export LD_LIBRARY_PATH=$ZTROOT/lib

# start zerotier
$ZTROOT/zerotier-one -d >> $ZT_LOG 2>&1 &

# ----------------------------------------------
#             CLI before login
# ----------------------------------------------

touch $PIPE_CLI
inotifyd $MODDIR/handle.sh $PIPE_CLI:w &>/dev/null &  # toybox inotifyd bug: needs an extra character after colon

# ----------------------------------------------
#             APP after login
# ----------------------------------------------

wait_until_login

if [[ -d "$APPROOT" ]]; then
  rm -rf $APPROOT/run
  mkdir -p $APPROOT/run

  cp $ZTROOT/home/authtoken.secret $APPROOT/run/authtoken
  touch $PIPE_APP
  chmod 666 $APPROOT/run/authtoken $PIPE_APP
  inotifyd $MODDIR/handle.sh $PIPE_APP:w &>/dev/null &
fi