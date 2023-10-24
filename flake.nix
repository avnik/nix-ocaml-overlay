{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-parts = {
          url = "github:hercules-ci/flake-parts";
          inputs.nixpkgs-lib.follows = "nixpkgs";
        };

    # utilities
    flake-root.url = "github:srid/flake-root";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };
    };
    outputs = { self, flake-parts, ...}@inputs:  flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [
        inputs.devshell.flakeModule
        inputs.flake-root.flakeModule
        inputs.treefmt-nix.flakeModule
        ./checks.nix
        ./formatter.nix
      ];
      flake = { lib, ...}: {
        nixosConfigurations = {
          crossed = lib.nixosSystem {
            system = "aarch64-linux";
            modules = [
              {
                nixpkgs.hostPlatform.system = "aarch64-linux";
                nixpkgs.buildPlatform.system = "x86_64-linux";
                nixpkgs.overlays =  [
                  (import ./ocaml.nix { inherit (inputs) nixpkgs; })
                  (final: prev: {
                     caml-crush = final.callPackage ./caml-crush.nix { };
                  })
                ];
              }
              ({ pkgs, ...}: {
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
      perSystem = { self', inputs', system, pkgs, ... }: {
        packages = {
         crossed = self.nixosConfigurations.crossed.config.system.build.toplevel;
        };
      };
    };
}
