#!/bin/sh
PATH=/data/adb/ap/bin:/data/adb/ksu/bin:/data/adb/magisk:$PATH

# require mountify
if [ ! -f /data/adb/modules/mountify/config.sh ] && [ ! -f /data/adb/modules_update/mountify/config.sh ]; then
	abort "[!] mountify is required for this module!"
fi

# skip mount
touch $MODPATH/skip_mount

# functions
service_perm() {
	chcon -r u:object_r:system_file:s0 $1
	chown root:shell $1
	chmod +x $1
}

# vendor_sepolicy.cil
vendor_sepolicy="/system/vendor/etc/selinux/vendor_sepolicy.cil"
if grep -q "lineage" $vendor_sepolicy >/dev/null 2>&1; then
	echo "[+] creating vendor_sepolicy.cil"
	# original
	mkdir -p "$MODPATH/system/vendor/etc/selinux"
	cat $vendor_sepolicy > "$MODPATH$vendor_sepolicy"
	# prep file for boot-complete mount
	mkdir -p "$MODPATH/latemount/system/vendor/etc/selinux"
	grep -v "lineage" $vendor_sepolicy > "$MODPATH/latemount$vendor_sepolicy"	
else
	echo "[!] skipping vendor_sepolicy.cil as lineage was not found"
fi

# compatibility_matrix.device.xml
compatibility_matrix="/system/etc/vintf/compatibility_matrix.device.xml"
if grep -q "lineage" $compatibility_matrix >/dev/null 2>&1; then
	echo "[+] creating compatibility_matrix.device.xml"
	# original
	mkdir -p "$MODPATH/system/etc/vintf"
	cat $compatibility_matrix > "$MODPATH$compatibility_matrix"
	# prep file for boot-complete mount
	mkdir -p "$MODPATH/latemount/system/etc/vintf"
	grep -v lineage $compatibility_matrix > "$MODPATH/latemount$compatibility_matrix"
else
	echo "[!] skipping compatibility_matrix.device.xml as lineage was not found"
fi

echo "[+] creating filtered /system/bin/service"
# routine
# create our dir
mkdir -p "$MODPATH/system/bin"
# copy service bindary
cp -f /system/bin/service "$MODPATH/system/bin/service.orig"
if [ -f /system/bin/service.orig ]; then
	cp -f /system/bin/service.orig "$MODPATH/system/bin/service.orig"	
fi
service_perm "$MODPATH/system/bin/service.orig"

# replace with a script that filters its output
echo "IyEvYmluL3NoCi9zeXN0ZW0vYmluL3NlcnZpY2Uub3JpZyAiJEAiIHwgc2VkICdzL2xpbmVhZ2UvL2c7IHMvTGluZWFnZS8vZycK" | base64 -d > "$MODPATH/system/bin/service"
service_perm "$MODPATH/system/bin/service"

# try to copy its filesize
SERVICE_ORIGINAL_SIZE=$(busybox stat -c%s "$MODPATH/system/bin/service.orig")
FILTER_SCRIPT_SIZE=$(busybox stat -c%s "$MODPATH/system/bin/service")
dummy_bytes=$(( SERVICE_ORIGINAL_SIZE - FILTER_SCRIPT_SIZE - 3 ))

if [ $dummy_bytes -lt 1 ]; then
	dummy_bytes=30000
fi

# generate random bytes from /dev/urandom
echo "# $(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c $dummy_bytes )" >> "$MODPATH/system/bin/service"

# EOF
