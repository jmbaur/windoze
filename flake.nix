{
  description = "windoze";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs: with inputs; {
    overlays.default = final: prev: {
      windoze = prev.writeShellApplication {
        name = "windoze";
        runtimeInputs = [ prev.qemu ];
        text = builtins.readFile ./windoze.bash;
      };
    };
  } //
  flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
    let pkgs = import nixpkgs {
      inherit system; overlays = [ self.overlays.default ];
    }; in
    {
      packages = {
        windoze = pkgs.windoze;
        default = self.packages.${system}.windoze;
      };
      devShells.default = pkgs.mkShell {
        buildInputs = [ self.packages.${system}.default ];
        # Put the disk image in the current directory for development.
        WINDOZE_DISK_LOCATION = "windoze.qcow2";
      };
    });
}
