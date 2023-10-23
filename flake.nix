{
  description = "Create, initialize, and run Windows VMs";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = inputs: with inputs; let
    forAllSystems = f: nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ] (system: f {
      inherit system;
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    });
  in
  {
    overlays.default = final: prev: {
      virtio-win-iso = prev.callPackage "${prev.path}/nixos/lib/make-iso9660-image.nix" {
        isoName = "virtio-win.iso";
        volumeID = "virtio-win-iso";
        contents = [{ source = prev.virtio-win; target = "/"; }];
        syslinux = null;
      };
      windoze = prev.writeShellApplication {
        name = "windoze";
        runtimeInputs = [ prev.qemu ];
        text = builtins.readFile (prev.substituteAll {
          src = ./windoze.bash;
          virtioIso = final.virtio-win-iso;
        });
      };
    };
    legacyPackages = forAllSystems
      ({ pkgs, ... }: pkgs);
  };
}

