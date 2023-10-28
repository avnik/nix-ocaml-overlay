{self, ...}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    osuper,
    callPackage,
    ...
  }: {
    ocaml = callPackage ../cross/ocaml-compiler.nix {
      inherit
        osuper
        ;
      natocamlPackages = osuper.nativeOCamlPackages;
    };
  })
