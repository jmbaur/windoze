#!/usr/bin/env bash

# Create disk
# qemu-img create -f qcow2 WindowsVM.img 40G

# First time install:
# ./boot.sh -boot d -drive file=WINDOWS.iso,media=cdrom -drive file=DRIVER.iso,media=cdrom

# Bus 005 Device 019: ID 04e8:6860 Samsung Electronics Co., Ltd Galaxy A5 (MTP)
# Bus 005 Device 022: ID 04e8:685d Samsung Electronics Co., Ltd GT-I9100 Phone [Galaxy S II] (Download mode)

exec qemu-system-x86_64 -enable-kvm \
	-cpu host \
        -smp sockets=1,cores=4,threads=1 \
	-drive file=WindowsVM.img,if=virtio \
	-net nic -net user,hostname=windowsvm \
	-device usb-ehci,id=ehci \
	-device usb-host,bus=ehci.0,vendorid=0x04e8,productid=0x685d \
	-m 2G \
	-monitor stdio \
	-name "Windows" \
	-usb \
	"$@"
