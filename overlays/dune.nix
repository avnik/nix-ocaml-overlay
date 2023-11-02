{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    oself,
    osuper,
    lib,
    isCross,
    ...
  }: lib.optionalAttrs isCross {
      dune_2 = osuper.nativeOCamlPackages.dune_2;
      dune_3 = osuper.nativeOCamlPackages.dune_3;
      dune =
        if lib.versionOlder "4.06" osuper.ocaml.version
        then osuper.nativeOCamlPackages.dune_2
        else osuper.nativeOCamlPackages.dune_1;
  })
