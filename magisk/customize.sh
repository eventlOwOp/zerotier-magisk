#!/system/bin/sh

SKIPUNZIP=1
ASH_STANDALONE=0

ZTPATH=/data/adb/zerotier
SYSBIN=/system/bin

ui_print "- unzip"
unzip -o $ZIPFILE -x 'META-INF/*' -d $MODPATH >&2

ui_print "- create work dir"
rm -rf $ZTPATH/lib $ZTPATH/run
mkdir -p $ZTPATH/run $ZTPATH/home
mv $MODPATH/zerotier/* $ZTPATH
ln -sf $ZTPATH/zerotier-one $ZTPATH/zerotier-cli
ln -sf $ZTPATH/zerotier-one $ZTPATH/zerotier-idtool

ui_print "- link to system"
mkdir -p $MODPATH$SYSBIN
ln -sf $ZTPATH/zerotier.sh $MODPATH$SYSBIN/zerotier.sh
ln -sf $ZTPATH/zerotier-cli $MODPATH$SYSBIN/zerotier-cli
ln -sf $ZTPATH/zerotier-idtool $MODPATH$SYSBIN/zerotier-idtool

ui_print "- set file permission"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $ZTPATH 0 0 0755 0644
set_perm $MODPATH/handle.sh 0 0 0755
set_perm $ZTPATH/zerotier.sh 0 0 0755
set_perm $ZTPATH/zerotier-one 0 0 0755

ui_print "- installed"

ui_print "---------- information -----------"
ui_print "- zerotier root: $ZTPATH"
ui_print "- zerotier version: $(grep_prop version $TMPDIR/module.prop)"


