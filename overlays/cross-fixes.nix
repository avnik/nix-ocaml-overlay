{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    osuper,
    ...
  }: {
    pyml = osuper.pyml.override {utop = null;};
    ocaml_pcre = osuper.ocaml_pcre.overrideAttrs (_o: {
      nativeBuildInputs = [osuper.dune-configurator];
      buildInputs = [];
    });
  })
