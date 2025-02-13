# spoof_vendor_sepolicy

A demo for integration of [mountify's standalone-script](https://github.com/backslashxx/mountify/tree/standalone-script).

Filters:
- /vendor/etc/selinux/vendor_sepolicy.cil
- /system/etc/vintf/compatibility_matrix.device.xml
- /system/bin/service

Tries to evade [Root Detector](https://github.com/reveny/Android-Native-Root-Detector)'s LineageOS detections.
