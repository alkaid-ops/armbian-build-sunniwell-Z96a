#!/bin/sh
set -eu
BOOT_DIR="${1:-/boot}"
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC_SCR="$HERE/boot-usb-first.scr"

[ "$(id -u)" = 0 ] || { echo "run as root" >&2; exit 1; }
[ -f "$BOOT_DIR/boot.scr" ] || { echo "missing $BOOT_DIR/boot.scr" >&2; exit 1; }
[ -f "$SRC_SCR" ] || { echo "missing $SRC_SCR" >&2; exit 1; }
if command -v findmnt >/dev/null 2>&1; then
	src=$(findmnt -n -o SOURCE "$BOOT_DIR" 2>/dev/null || true)
	case "$src" in
		/dev/sd*|/dev/nvme*|/dev/usb*) echo "refusing to modify a USB-mounted boot dir: $src" >&2; exit 1;;
	esac
fi
if [ ! -f "$BOOT_DIR/boot-bsp.scr" ]; then
	cp -p "$BOOT_DIR/boot.scr" "$BOOT_DIR/boot-bsp.scr"
	echo "saved original boot script as $BOOT_DIR/boot-bsp.scr"
else
	echo "keeping existing $BOOT_DIR/boot-bsp.scr"
fi
cp "$SRC_SCR" "$BOOT_DIR/boot.scr.new"
sync
cp "$BOOT_DIR/boot.scr.new" "$BOOT_DIR/boot.scr"
sync
echo "installed USB-first boot.scr"
echo "rollback: cp -p $BOOT_DIR/boot-bsp.scr $BOOT_DIR/boot.scr"
