{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
  image-name = "WindowsVM.img";
  image-size = "40G";
  create = writeShellScriptBin "create-img" ''
    qemu-img create -f qcow2 ${image-name} ${image-size}
  '';
  boot = writeShellScriptBin "boot-img" ''
    exec qemu-system-x86_64 -enable-kvm \
      -cpu host \
      -smp sockets=1,cores=4,threads=1 \
      -drive file=${image-name},if=virtio \
      -net nic -net user,hostname=windowsvm \
      -m 2G \
      -monitor stdio \
      -name "Windows" \
      -usb \
      "$@"
  '';
  init = writeShellScriptBin "init-img" ''
    exec ${boot}/bin/boot-img \
      -boot d \
      -drive file=WINDOWS.iso,media=cdrom \
      -drive file=DRIVER.iso,media=cdrom
  '';
in
mkShell {
  buildInputs = [
    boot
    create
    init
  ];
}
