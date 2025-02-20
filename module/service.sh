#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH
MODDIR="${0%/*}"

# wait for boot-complete
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 1
done

# require mountify
if [ -f /data/adb/modules/mountify/config.sh ]; then
	. /data/adb/modules/mountify/config.sh
else
	exit 1
fi

if [ -z $FAKE_MOUNT_NAME ]; then
	exit 1
fi

[ -w /mnt ] && MNT_TARGET="/mnt/$FAKE_MOUNT_NAME"
[ -w /mnt/vendor ] && MNT_TARGET="/mnt/vendor/$FAKE_MOUNT_NAME"

cat "$MODDIR/latemount/system/etc/vintf/compatibility_matrix.device.xml" > "$MNT_TARGET/etc/vintf/compatibility_matrix.device.xml"
cat "$MODDIR/latemount/system/vendor/etc/selinux/vendor_sepolicy.cil" > "$MNT_TARGET/vendor/etc/selinux/vendor_sepolicy.cil"



# EOF
