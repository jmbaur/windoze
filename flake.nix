{
  description = "windoze";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = inputs: with inputs; let
    forAllSystems = cb: nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ] (system: cb {
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
    packages = forAllSystems ({ pkgs, ... }: { default = pkgs.windoze; });
    apps = forAllSystems ({ pkgs, ... }: { default = { type = "app"; program = "${pkgs.windoze}/bin/windoze"; }; });
  };
}
