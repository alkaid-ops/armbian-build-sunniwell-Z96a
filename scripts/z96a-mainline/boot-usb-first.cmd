# Z96A USB-first launcher v3.
# Installed as /boot/boot.scr on eMMC; original BSP script must be /boot/boot-bsp.scr.
# The USB stick keeps its normal Armbian boot.scr unchanged.

setenv z96a_script_addr "0x10000000"
setenv z96a_diag_addr "0x10100000"
setenv z96a_saved_devtype "${devtype}"
setenv z96a_saved_devnum "${devnum}"
setenv z96a_saved_bootpart "${distro_bootpart}"
setenv z96a_saved_prefix "${prefix}"

setenv z96a_diag_version "v3-power-diag"
setenv z96a_diag_devtype "${devtype}"
setenv z96a_diag_devnum "${devnum}"
setenv z96a_diag_bootpart "${distro_bootpart}"
setenv z96a_diag_prefix "${prefix}"

# Z96A USB-A VBUS enables. Rockchip U-Boot bank names are A..E:
#   GPIO0_A6 -> A6, GPIO4_B1 -> E1, GPIO4_B3 -> E3.
# GPIO2_D7 -> C31 is the internal keyboard rail.
setenv z96a_diag_gpio_a6 fail
setenv z96a_diag_gpio_e1 fail
setenv z96a_diag_gpio_e3 fail
setenv z96a_diag_gpio_c31 fail
if gpio set A6; then setenv z96a_diag_gpio_a6 ok; fi
if gpio set E1; then setenv z96a_diag_gpio_e1 ok; fi
if gpio set E3; then setenv z96a_diag_gpio_e3 ok; fi
if gpio set C31; then setenv z96a_diag_gpio_c31 ok; fi

# Give the load switches time to ramp before HCD probing.
sleep 1
echo "Z96A: USB power enabled; starting USB"
usb stop
setenv z96a_diag_usb_start fail
if usb start; then setenv z96a_diag_usb_start ok; fi

setenv z96a_diag_usb_part0 fail
setenv z96a_diag_usb_part1 fail
if part list usb 0; then setenv z96a_diag_usb_part0 ok; fi
if part list usb 1; then setenv z96a_diag_usb_part1 ok; fi

setenv z96a_diag_usb_load fail
setenv z96a_diag_usb_source "none"

if load usb 0:1 ${z96a_script_addr} boot.scr; then
	setenv z96a_diag_usb_load ok
	setenv z96a_diag_usb_source "usb 0:1 boot.scr"
	setenv devtype usb
	setenv devnum 0
	setenv distro_bootpart 1
	setenv prefix /
	echo "Z96A: USB boot.scr loaded from usb 0:1"
	source ${z96a_script_addr}
	echo "Z96A: USB boot script returned; falling back"
else
	if load usb 0:1 ${z96a_script_addr} /boot.scr; then
		setenv z96a_diag_usb_load ok
		setenv z96a_diag_usb_source "usb 0:1 /boot.scr"
		setenv devtype usb
		setenv devnum 0
		setenv distro_bootpart 1
		setenv prefix /
		echo "Z96A: USB boot.scr loaded from usb 0:1 /boot.scr"
		source ${z96a_script_addr}
		echo "Z96A: USB boot script returned; falling back"
	else
		if load usb 0:2 ${z96a_script_addr} boot.scr; then
			setenv z96a_diag_usb_load ok
			setenv z96a_diag_usb_source "usb 0:2 boot.scr"
			setenv devtype usb
			setenv devnum 0
			setenv distro_bootpart 2
			setenv prefix /
			echo "Z96A: USB boot.scr loaded from usb 0:2"
			source ${z96a_script_addr}
			echo "Z96A: USB boot script returned; falling back"
		else
			if load usb 1:1 ${z96a_script_addr} boot.scr; then
				setenv z96a_diag_usb_load ok
				setenv z96a_diag_usb_source "usb 1:1 boot.scr"
				setenv devtype usb
				setenv devnum 1
				setenv distro_bootpart 1
				setenv prefix /
				echo "Z96A: USB boot.scr loaded from usb 1:1"
				source ${z96a_script_addr}
				echo "Z96A: USB boot script returned; falling back"
			fi
		fi
	fi
fi

setenv devtype "${z96a_saved_devtype}"
setenv devnum "${z96a_saved_devnum}"
setenv distro_bootpart "${z96a_saved_bootpart}"
setenv prefix "${z96a_saved_prefix}"

# Persist the probe result to the eMMC FAT boot partition. On Linux this is
# normally visible as /boot/z96a-usb-diag.txt.
echo "Z96A: writing USB diagnosis to eMMC boot partition"
if env export -t ${z96a_diag_addr}; then
	if fatwrite ${z96a_saved_devtype} ${z96a_saved_devnum}:${z96a_saved_bootpart} ${z96a_diag_addr} z96a-usb-diag.txt ${filesize}; then
		echo "Z96A: diagnosis saved as z96a-usb-diag.txt"
	fi
fi

echo "Z96A: booting eMMC BSP fallback /boot-bsp.scr"
if load ${z96a_saved_devtype} ${z96a_saved_devnum}:${z96a_saved_bootpart} ${z96a_script_addr} ${z96a_saved_prefix}boot-bsp.scr; then
	source ${z96a_script_addr}
fi
echo "Z96A: neither USB nor BSP boot script could be booted"
