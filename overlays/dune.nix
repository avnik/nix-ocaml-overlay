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
    buildPackages,
    crossName,
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
      buildDunePackage = args:
        builtins.trace "buildDunePackage ${args.pname} ${crossName}" (osuper.buildDunePackage (
          {
            buildPhase = ''
              echo "Dune buildPhase"
              runHook preBuild
              dune build -p ${args.pname} ''${enableParallelBuilding:+-j $NIX_BUILD_CORES} -x ${crossName}
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              dune install ${args.pname} -x ${crossName} \
                --prefix $out --libdir $(dirname $OCAMLFIND_DESTDIR) \
                --docdir $out/share/doc --man $out/share/man
              runHook postInstall
            '';
          }
          // args
        ))
        .overrideAttrs (o: {
          nativeBuildInputs =
            (o.nativeBuildInputs or []) ++ [buildPackages.stdenv.cc];
        });  
  })
