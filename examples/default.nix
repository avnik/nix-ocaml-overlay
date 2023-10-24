{self, ...}: {
  flake = {lib, ...}: {
    nixosConfigurations = {
      crossed = lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          {
            nixpkgs.hostPlatform.system = "aarch64-linux";
            nixpkgs.buildPlatform.system = "x86_64-linux";
            nixpkgs.overlays = [
              self.overlays.default
              (final: _prev: {
                caml-crush = final.callPackage ./caml-crush.nix {};
              })
            ];
          }
          ({pkgs, ...}: {
            environment.systemPackages = with pkgs; [
              # List problematic packages here
              caml-crush
            ];
            boot.isContainer = true; # Don't build kernel and other slow things
          })
        ];
      };
    };
  };
  perSystem = {system, ...}: {
    packages = {
      crossed = self.nixosConfigurations.crossed.config.system.build.toplevel;
    };
  };
}
