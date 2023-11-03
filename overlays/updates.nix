{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    osuper,
    final,
    ...
  }: {
    dune_3 = osuper.dune_3.overrideAttrs (_o: {
      src = builtins.fetchurl {
        url = "https://github.com/ocaml/dune/releases/download/3.11.1/dune-3.11.1.tbz";
        sha256 = "0w9zxp2hzi4ndiraclv90jm2nycq82xri7dzyc27dbxdml3j6vw6";
      };
    });
    topkg = osuper.topkg.overrideAttrs (_: {
      src = builtins.fetchurl {
        url = https://erratique.ch/software/topkg/releases/topkg-1.0.6.tbz;
        sha256 = "11ycfk0prqvifm9jca2308gw8a6cjb1hqlgfslbji2cqpan09kpq";
      };
    });
  })
