#!/system/bin/sh
MODDIR=${0%/*}
LOGFILE="$MODDIR/hbl.log"

# 等待开机完成再执行
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 1
done

rm -f "$LOGFILE"

echo "===== $(date) 开始检查 =====" >> "$LOGFILE"

check_reset_prop() {
  NAME=$1
  EXPECTED=$2
  VALUE=$(resetprop "$NAME" 2>/dev/null)
  if [ -z "$VALUE" ]; then
    echo "[跳过] $NAME 当前为空,未修改" >> "$LOGFILE"
  elif [ "$VALUE" = "$EXPECTED" ]; then
    : # 已经是期望值,不记录,减少日志噪音
  else
    resetprop -n "$NAME" "$EXPECTED"
    echo "[修改] $NAME : $VALUE -> $EXPECTED" >> "$LOGFILE"
  fi
}

contains_reset_prop() {
  NAME=$1
  CONTAINS=$2
  NEWVAL=$3
  CURVAL=$(resetprop "$NAME" 2>/dev/null)
  case "$CURVAL" in
    *"$CONTAINS"*)
      resetprop -n "$NAME" "$NEWVAL"
      echo "[修改] $NAME : $CURVAL -> $NEWVAL" >> "$LOGFILE"
      ;;
  esac
}

check_reset_prop "ro.boot.vbmeta.device_state" "locked"
check_reset_prop "ro.boot.verifiedbootstate" "green"
check_reset_prop "ro.boot.flash.locked" "1"
check_reset_prop "ro.boot.veritymode" "enforcing"
check_reset_prop "ro.boot.warranty_bit" "0"
check_reset_prop "ro.warranty_bit" "0"
check_reset_prop "ro.debuggable" "0"
check_reset_prop "ro.force.debuggable" "0"
check_reset_prop "ro.secure" "1"
check_reset_prop "ro.adb.secure" "1"
check_reset_prop "ro.build.type" "user"
check_reset_prop "ro.build.tags" "release-keys"
check_reset_prop "ro.vendor.boot.warranty_bit" "0"
check_reset_prop "ro.vendor.warranty_bit" "0"
check_reset_prop "vendor.boot.vbmeta.device_state" "locked"
check_reset_prop "vendor.boot.verifiedbootstate" "green"
check_reset_prop "sys.oem_unlock_allowed" "0"

# MIUI
check_reset_prop "ro.secureboot.lockstate" "locked"

# Realme
check_reset_prop "ro.boot.realmebootstate" "green"
check_reset_prop "ro.boot.realme.lockstate" "1"

# 隐藏从 recovery 启动的痕迹
contains_reset_prop "ro.bootmode" "recovery" "unknown"
contains_reset_prop "ro.boot.bootmode" "recovery" "unknown"
contains_reset_prop "vendor.boot.bootmode" "recovery" "unknown"

echo "===== 检查结束,BL隐藏完成 =====" >> "$LOGFILE"
echo "" >> "$LOGFILE"