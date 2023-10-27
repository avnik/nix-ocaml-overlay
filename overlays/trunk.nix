{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) newOCamlScope;
in
  _final: prev:
    prev
    // {
      ocaml-ng =
        prev.ocaml-ng
        // {
          ocamlPackages_4_14 = prev.ocaml-ng.ocamlPackages_4_14.overrideScope' (_oself: osuper: {
            ocaml = osuper.ocaml.overrideAttrs (_: {
              hardeningDisable = ["strictoverflow"];
            });
          });

          ocamlPackages_trunk = newOCamlScope {
            major_version = "5";
            minor_version = "2";
            patch_version = "0+trunk";
            hardeningDisable = ["strictoverflow"];
            src = prev.fetchFromGitHub {
              owner = "ocaml";
              repo = "ocaml";
              rev = "8e595b2ffb56eacf08e4587d449f81ed544aab1e";
              hash = "sha256-1EgkG+FEZtK2uzIXLDouzDa+UHeclASt++hdhrOo024=";
            };
          };
          ocamlPackages_jst = prev.ocaml-ng.ocamlPackages_4_14.overrideScope' (_oself: osuper: {
            ocaml =
              (prev.callPackage
                (import "${inputs.nixpkgs}/pkgs/development/compilers/ocaml/generic.nix" {
                  major_version = "4";
                  minor_version = "14";
                  patch_version = "1+jst";
                })
                {})
              .overrideAttrs (_o: {
                src = prev.fetchFromGitHub {
                  owner = "ocaml-flambda";
                  repo = "ocaml-jst";
                  rev = "e3076d2e7321a8e8ff18e560ed7a55d6ff0ebf04";
                  hash = "sha256-y5p73ZZtwkgUzvCHlE9nqA2OdlDbYWr8wnWRhYH82hE=";
                };
                hardeningDisable = ["strictoverflow"];
              });

            dune_3 = osuper.dune_3.overrideAttrs (_: {
              postPatch = ''
                substituteInPlace boot/bootstrap.ml --replace 'v >= (5, 0, 0)' "true"
                substituteInPlace boot/duneboot.ml --replace 'ocaml_version >= (5, 0)' "true"
                substituteInPlace src/ocaml-config/ocaml_config.ml --replace 'version >= (5, 0, 0)' "true"
                substituteInPlace src/ocaml/version.ml --replace 'version >= (5, 0, 0)' "true"
              '';
            });
          });
        };
    }
