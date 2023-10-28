{self, ...}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    buildPackages,
    stdenv,
    packageSetName,
    ...
  }: {
    nativeOCamlPackages = buildPackages.ocaml-ng.${packageSetName};
  })
