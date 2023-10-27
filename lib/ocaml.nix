{
  inputs,
  lib,
  ...
}: {
  flake.lib = rec {
    ocamlVersions = [
      "4_06"
      "4_08"
      "4_09"
      "4_10"
      "4_11"
      "4_12"
      "4_13"
      "4_14"
      "5_0"
      "5_1"
      "trunk"
      "jst"
    ];
    newOCamlScope = {
      major_version,
      minor_version,
      patch_version,
      parentScope,
      callPackage, # Kludge, callPackage avaliable in points where we use newOCamlScope
      src,
      ...
    } @ extraOpts:
      parentScope.overrideScope'
      (_oself: _osuper: {
        ocaml = (callPackage
          (import "${inputs.nixpkgs}/pkgs/development/compilers/ocaml/generic.nix" {
            inherit major_version minor_version patch_version;
          })
          {})
        .overrideAttrs (_: {inherit src;} // extraOpts);
      });

    /*
    Inject ocaml overlay for all known ocaml versions
    */
    overlayOCamlPackages = ocaml-ng: overlay: let
      overlaySinglePackageSet = version: let
        attrName = "ocamlPackages_${version}";
      in
        lib.nameValuePair attrName (ocaml-ng.${attrName}.overrideScope' overlay);
    in
      builtins.listToAttrs (builtins.map overlaySinglePackageSet ocamlVersions);

    /*
    Lift OCaml overlay to regular one
    */
    liftOCamlOverlay = overlay: _final: prev:
      prev
      // {
        ocaml-ng = overlayOCamlPackages prev.ocaml-ng overlay;
      };

    /*
    Lift OCaml overlay to regular one, also pass additional utilities
    Note: in distinction of liftOCamlOverlay here overlay passed with an attrset parameter
    (used to inject cross-compiler)
    */
    liftOCamlOverlay' = overlay: final: _prev:
      liftOCamlOverlay (oself: osuper:
        overlay {
          inherit oself osuper;
          inherit (final) callPackage buildPackages stdenv;
          inherit (inputs) nixpkgs;
        });
  };
}
