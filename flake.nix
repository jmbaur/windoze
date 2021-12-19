{
  description = "A very basic flake";
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11-small";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    with pkgs; {
      devShell =
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
        };
    });
}
