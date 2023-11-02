{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    osuper,
    lib,
    isCross,
    ...
  }: lib.optionalAttrs isCross {
    ocamlbuild = osuper.nativeOCamlPackages.ocamlbuild;
  })
