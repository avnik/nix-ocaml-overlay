{self, ...}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    buildPackages,
    packageSetName,
    ...
  }: {
    nativeOCamlPackages = buildPackages.ocaml-ng.${packageSetName};
  })
