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
    ...
  }: {
    camlzip = osuper.camlzip.overrideAttrs (_: {
      postInstall = ''
        ln -sfn $OCAMLFIND_DESTDIR/{,caml}zip
      '';
    });
    camlp4 = osuper.camlp4.overrideAttrs (_: {
      configurePlatforms = [];
    });
    dune-configurator = osuper.dune-configurator.overrideAttrs (_o: {
      preBuild = "rm -rf vendor/csexp vendor/pp";
    });
    pyml = osuper.pyml.override {utop = null;};
    ocaml_pcre = osuper.ocaml_pcre.overrideAttrs (_o: {
      nativeBuildInputs = [osuper.dune-configurator];
      buildInputs = [];
    });
  })
