#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
OUT="$ROOT/output/z96a-mainline-artifacts"
mkdir -p "$OUT"
cp -v "$ROOT"/output/debs/linux-image-*.deb "$OUT"/ 2>/dev/null || true
cp -v "$ROOT"/output/debs/linux-dtb-*.deb "$OUT"/ 2>/dev/null || true
cp -v "$ROOT"/output/debs/linux-headers-*.deb "$OUT"/ 2>/dev/null || true
cp -v "$ROOT"/output/images/*.img.xz "$OUT"/ 2>/dev/null || true
cp -v "$ROOT"/output/images/*.sha "$OUT"/ 2>/dev/null || true
cp -v "$ROOT"/scripts/z96a-mainline/boot-usb-first.scr "$OUT"/
cp -v "$ROOT"/scripts/z96a-mainline/boot-usb-first.cmd "$OUT"/
cp -v "$ROOT"/scripts/z96a-mainline/install-usb-first-boot.sh "$OUT"/
cp -v "$ROOT"/scripts/z96a-mainline/uninstall-usb-first-boot.sh "$OUT"/
cp -v "$ROOT"/scripts/z96a-mainline/README.md "$OUT"/
( cd "$OUT" && find . -maxdepth 1 -type f ! -name SHA256SUMS -printf '%f\n' | sort | xargs sha256sum > SHA256SUMS )
ls -lh "$OUT"
