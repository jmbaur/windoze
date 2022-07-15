{
  description = "A very basic flake";
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11-small";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let pkgs = nixpkgs.legacyPackages.${system}; in
    with pkgs; {
      devShell =
        let
          image-name = "WindowsVM.img";
          create-img = writeShellScriptBin "create-img" ''
            ${pkgs.qemu}/bin/qemu-img create -f qcow2 ${image-name} ''${IMAGE_SIZE:-40G}
          '';
          boot-img = writeShellScriptBin "boot-img" ''
            ${pkgs.qemu}/bin/qemu-system-x86_64 \
              -name "Windows" \
              -display gtk \
              -monitor stdio \
              -enable-kvm \
              -cpu host \
              -m 4G \
              -smp 4 \
              -drive file=${image-name},media=disk,if=virtio \
              -nic user,model=virtio-net-pci \
              "$@"
          '';
          init-img = writeShellScriptBin "init-img" ''
            ${boot-img}/bin/boot-img \
              -boot d \
              -cdrom ''${WINDOWS_ISO_FILE:-windows.iso} \
              -drive file=''${VIRTIO_ISO_FILE:-virtio.iso},media=cdrom
          '';
        in
        mkShell {
          buildInputs = [ boot-img create-img init-img ];
        };
    });
}
