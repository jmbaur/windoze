# shellcheck shell=bash

image_name=${WINDOZE_DISK_LOCATION:-~/Documents/windoze.qcow2}
image_size=${WINDOZE_DISK_SIZE:-50G}
memory=${WINDOZE_MEM:-4G}
cpu=${WINDOZE_CPU:-2}
os_iso=${WINDOZE_OS_ISO_LOCATION:-~/Downloads/windows.iso}
virtio_iso=${WINDOZE_VIRTIO_ISO_LOCATION:-~/Downloads/virtio.iso}

run_args=(
	-name "windoze"
	-display gtk
	-usb -device usb-tablet
	-monitor stdio
	-enable-kvm
	-cpu host
	-m "$memory"
	-smp "$cpu"
	-drive "file=${image_name},media=disk,if=virtio"
	-nic "user,model=virtio-net-pci"
)

function usage() {
	cat <<EOF
Create, initialize, and run Windows VMs

Usage:
  windoze [command] [flags/args passed to qemu]

Available Commands:
  create Create the VM disk image
  init   Initialize the VM, good for first time VM installation
  run    Run the VM
EOF
}

# https://github.com/NixOS/nixpkgs/blob/afcc5dfba25d98df876de469cc63e3444f41aee2/pkgs/applications/virtualization/qemu/default.nix#L252
if ! command -v qemu-kvm >/dev/null; then
	cat <<EOF
This program is officially packaged using nix. Nix installs a qemu-kvm
executable that is symlinked to the correct qemu-system-* command for a
machines given architecture, but the qemu-kvm command was not found. Please use
the official packaging method for this program.
EOF
	exit 1
fi

case ${1:-} in
	create)
		exec -a "$0" qemu-img create -f qcow2 "$image_name" "$image_size" "${@:2}"
		;;
	init)
		run_args+=(
			-boot d
			-cdrom "$os_iso"
			-drive "file=${virtio_iso},media=cdrom"
		)
		exec -a "$0" qemu-kvm "${run_args[@]}" "${@:2}"
		;;
	run)
		exec -a "$0" qemu-kvm "${run_args[@]}" "${@:2}"
		;;
	*)
		usage
		exit 1
		;;
esac
