{nixpkgs}: (
  final: prev: let
    overlayOCamlPackages = import ./lib/overlay-ocaml-packages.nix;
    cross = final.callPackage ./cross/ocaml.nix {};
    crossOverlays = cross;
    #crossOverlays = if final.stdenv.hostPlatform != final.stdenv.buildPlatform then cross else [];
    duneOverlay = oself: osuper: {
      dune =
        if prev.lib.versionOlder "4.06" oself.ocaml.version
        then oself.dune_2
        else osuper.dune_1;
    };
    super = prev;
  in overlayOCamlPackages {
    inherit super nixpkgs;
    overlays = crossOverlays ++ [duneOverlay];
    updateOCamlPackages = true;
  }
)
