{
  description = "windoze";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = inputs: with inputs; let
    forAllSystems = f: nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ] (system: f {
      inherit system;
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
    });
  in
  {
    overlays.default = final: prev: {
      windoze = prev.writeShellApplication {
        name = "windoze";
        runtimeInputs = [ prev.qemu ];
        text = builtins.readFile ./windoze.bash;
      };
    };
    legacyPackages = forAllSystems ({ pkgs, ... }: pkgs);
  };
}
