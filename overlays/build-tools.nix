{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    osuper,
    oself,
    final,
    lib,
    isCross,
    crossName,
    ...
  }: lib.optionalAttrs isCross {
    dune-configurator = osuper.nativeOCamlPackages.dune-configurator;
    ocamlbuild = osuper.nativeOCamlPackages.ocamlbuild;
    opaline = osuper.nativeOCamlPackages.opaline.override {ocamlPackages = osuper.nativeOCamlPackages;};
    topkg = oself.nativeOCamlPackages.topkg.overrideAttrs (_o: let
        natocamlPackages = oself.nativeOCamlPackages;
        natocaml = natocamlPackages.ocaml;
        natfindlib = natocamlPackages.findlib;
        run = "${natocaml}/bin/ocaml -I ${natfindlib}/lib/ocaml/${osuper.ocaml.version}/site-lib pkg/pkg.ml";
      in {
        selfBuild = true;

        passthru = {
          inherit run;
        };

        buildPhase = "${run} build";
        installPhase = "${natocamlPackages.opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR";

        setupHook = final.writeText "setupHook.sh" ''
          addToolchainVariable () {
            if [ -z "''${selfBuild:-}" ]; then
              export TOPKG_CONF_TOOLCHAIN="${crossName}"
            fi
          }

          addEnvHooks "$targetOffset" addToolchainVariable
        '';
      });
  })
