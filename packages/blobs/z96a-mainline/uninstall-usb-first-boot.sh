#!/bin/sh
set -eu
BOOT_DIR="${1:-/boot}"
[ "$(id -u)" = 0 ] || { echo "run as root" >&2; exit 1; }
[ -f "$BOOT_DIR/boot-bsp.scr" ] || { echo "missing $BOOT_DIR/boot-bsp.scr" >&2; exit 1; }
cp "$BOOT_DIR/boot-bsp.scr" "$BOOT_DIR/boot.scr.new"
sync
cp "$BOOT_DIR/boot.scr.new" "$BOOT_DIR/boot.scr"
sync
echo "restored original BSP boot.scr"
