# Z96A mainline USB test boot

## Flash the USB image

Use balenaEtcher and select this file directly; no decompression or mounting is needed:

`Armbian-unofficial_24.2.0-trunk_Z96a-v2-mainline_bookworm_mainline_7.2.11_minimal.img.xz`

The USB stick keeps its normal Armbian `boot.scr`. Do not replace it with the
USB-first wrapper; the wrapper belongs only in the eMMC `/boot` directory.

For the first hardware test, use the **USB 3.0 Type-A** port and a USB 2.0 or
USB 3.0 stick. Do not use the Type-C charging port as a boot port.

## One-time eMMC boot switch

Copy `boot-usb-first.scr` to the Z96A, then on the existing eMMC system:

```sh
cd /boot
sudo mv boot.scr boot-bsp.scr
sudo cp /path/to/boot-usb-first.scr boot.scr
sync
```

There is no need to mount any image. The USB-first `boot.scr`:

1. saves the eMMC boot context;
2. raises the Z96A USB-A VBUS enables (`A6`, `E1`, `E3`) and keyboard
   power (`C31`);
3. runs `usb start` and tries `usb 0:1`, `usb 0:2`, then `usb 1:1`;
4. calls the USB stick's original Armbian `boot.scr` if one is found;
5. otherwise writes `z96a-usb-diag.txt` to the eMMC FAT boot partition and
   runs `/boot-bsp.scr`.

If boot falls back to eMMC, inspect the diagnostic result from Linux:

```sh
cat /boot/z96a-usb-diag.txt
```

Interpretation:

- `z96a_diag_gpio_*_fail` means U-Boot could not map/control that rail.
- `z96a_diag_usb_start=ok` but `z96a_diag_usb_part0=fail` means
  `usb start` ran but no USB mass-storage device/partition was enumerated.
- `z96a_diag_usb_part0=ok` but `z96a_diag_usb_load=fail` means storage is
  visible but `boot.scr` was not readable from the FAT partition.
- `z96a_diag_usb_load=ok` means the wrapper found the USB script; if the board
  still returns to BSP, the USB kernel handoff itself failed.

A successful USB boot does not write the diagnostic file; run `uname -r` and
`findmnt /` after boot to confirm that the USB root is active.

## Rollback

```sh
cd /boot
sudo mv boot-bsp.scr boot.scr
sync
```

If the eMMC boot script is damaged, use Type-C Maskrom/RKDevTool recovery.

## Optional installer

`install-usb-first-boot.sh` performs the same backup and replacement and should
only be run from the eMMC system. `uninstall-usb-first-boot.sh` restores the
saved BSP script.
