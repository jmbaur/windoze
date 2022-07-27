# Helper script for creating and booting a Windows VM

## Building
`nix build`

## Running
`nix run`

## Configuration

### $WINDOZE_DISK_LOCATION
	default: ~/Documents/windoze.qcow2

### $WINDOZE_DISK_SIZE
	default: 50G

### $WINDOZE_MEM
	default: 4G

### $WINDOZE_CPU
	default: 2

### $WINDOZE_OS_ISO_LOCATION (only needed for VM initialization)
	default: ~/Downloads/windows.iso

### $WINDOZE_VIRTIO_ISO_LOCATION (only needed for VM initialization)
	default: ~/Downloads/virtio.iso
