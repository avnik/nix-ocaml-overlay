{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) liftOCamlOverlay' mergeInputs;
in
  liftOCamlOverlay' ({
    osuper,
    oself,
    final,
    lib,
    stdenv,
    crossName,
    isCross,
    ...
  }:
  let
    natocamlPackages = oself.nativeOCamlPackages;
    natocaml = natocamlPackages.ocaml;
    natfindlib = natocamlPackages.findlib;
    makeFindlibConf = nativePackage: package: let
      inputs =
        mergeInputs [
          "propagatedBuildInputs"
          "buildInputs"
          "checkInputs"
        ]
        package;
      natInputs =
        mergeInputs [
          "propagatedBuildInputs"
          "buildInputs"
          "nativeBuildInputs"
        ]
        nativePackage;

      path =
        builtins.concatStringsSep ":"
        (builtins.map (x: "${x.outPath}/lib/ocaml/${natocaml.version}/${crossName}-sysroot/lib")
          inputs);
      natPath =
        builtins.concatStringsSep ":"
        (builtins.map (x: "${x.outPath}/lib/ocaml/${natocaml.version}/site-lib")
          natInputs);

      native_findlib_conf = final.writeText "${package.name or package.pname}-findlib.conf" ''
        path="${natocaml}/lib/ocaml:${natfindlib}/lib/ocaml/${natocaml.version}/site-lib:${natPath}"
        ldconf="ignore"
        stdlib = "${natocaml}/lib/ocaml"
        ocamlc = "${natocaml}/bin/ocamlc"
        ocamlopt = "${natocaml}/bin/ocamlopt"
        ocamlcp = "${natocaml}/bin/ocamlcp"
        ocamlmklib = "${natocaml}/bin/ocamlmklib"
        ocamlmktop = "${natocaml}/bin/ocamlmktop"
        ocamldoc = "${natocaml}/bin/ocamldoc"
        ocamldep = "${natocaml}/bin/ocamldep"
      '';
      aarch64_findlib_conf = let
        inherit (oself) ocaml findlib;
      in
        final.writeText "${package.name or package.pname}-${crossName}.conf" ''
          path(${crossName}) = "${ocaml}/lib/ocaml:${findlib}/lib/ocaml/${ocaml.version}/site-lib:${path}"
          ldconf(${crossName})="ignore"
          stdlib(${crossName}) = "${ocaml}/lib/ocaml"
          ocamlc(${crossName}) = "${ocaml}/bin/ocamlc"
          ocamlopt(${crossName}) = "${ocaml}/bin/ocamlopt"
          ocamlcp(${crossName}) = "${ocaml}/bin/ocamlcp"
          ocamlmklib(${crossName}) = "${ocaml}/bin/ocamlmklib"
          ocamlmktop(${crossName}) = "${ocaml}/bin/ocamlmktop"
          ocamldoc(${crossName}) = "${natocaml}/bin/ocamldoc"
          ocamldep(${crossName}) = "${ocaml}/bin/ocamldep"
        '';
     findlib_conf = stdenv.mkDerivation {
        name = "${package.name or package.pname}-findlib-conf";
        version = "0.0.1";
        unpackPhase = "true";

        dontBuild = true;
        installPhase = ''
          mkdir -p $out/findlib.conf.d
          ln -sf ${native_findlib_conf} $out/findlib.conf
          ln -sf ${aarch64_findlib_conf} $out/findlib.conf.d/${crossName}.conf
        '';
      };
    in "${findlib_conf}/findlib.conf";

    fixOCamlPackage = b:
      b.overrideAttrs (_o: {
        OCAMLFIND_CONF = makeFindlibConf natocamlPackages b;
        OCAMLFIND_TOOLCHAIN = "${crossName}";
      });
  in
    (lib.mapAttrs
      (_: p:
        if (isCross && p ? overrideAttrs && !(lib.elem p [osuper.ocaml osuper.findlib]))
        then fixOCamlPackage p
        else p)
      osuper) //
  {
    findlib = osuper.findlib.overrideAttrs (_o: {
        postInstall = lib.optionalString isCross ''
          rm -rf $out/bin/ocamlfind
          cp ${natfindlib}/bin/ocamlfind $out/bin/ocamlfind
        '';

        passthru = {inherit makeFindlibConf;};

        setupHook = final.writeText "setupHook.sh" ''
          addOCamlPath () {
              if test -d "''$1/lib/ocaml/${oself.ocaml.version}/site-lib"; then
                  export OCAMLPATH="''${OCAMLPATH-}''${OCAMLPATH:+:}''$1/lib/ocaml/${oself.ocaml.version}/site-lib/"
              fi
              if test -d "''$1/lib/ocaml/${oself.ocaml.version}/site-lib/stublibs"; then
                  export CAML_LD_LIBRARY_PATH="''${CAML_LD_LIBRARY_PATH-}''${CAML_LD_LIBRARY_PATH:+:}''$1/lib/ocaml/${oself.ocaml.version}/site-lib/stublibs"
              fi
          }
          exportOcamlDestDir () {
              export OCAMLFIND_DESTDIR="''$out/lib/ocaml/${oself.ocaml.version}/${crossName}-sysroot/lib/"
          }
          createOcamlDestDir () {
              if test -n "''${createFindlibDestdir-}"; then
                mkdir -p $OCAMLFIND_DESTDIR
              fi
          }
          detectOcamlConflicts () {
            local conflict
            conflict="$(ocamlfind list |& grep "has multiple definitions" | grep -vE "bigarray|unix|str|stdlib|compiler-libs|threads|bytes|dynlink|findlib" || true)"
            if [[ -n "$conflict" ]]; then
              echo "Conflicting ocaml packages detected";
              echo "$conflict"
              exit 1
            fi
          }
          # run for every buildInput
          addEnvHooks "$targetOffset" addOCamlPath
          # run before installPhase, even without buildInputs, and not in nix-shell
          preInstallHooks+=(createOcamlDestDir)
          # run even in nix-shell, and even without buildInputs
          addEnvHooks "$hostOffset" exportOcamlDestDir
          # runs after all calls to addOCamlPath
          if [[ -z "''${dontDetectOcamlConflicts-}" ]]; then
            postHooks+=("detectOcamlConflicts")
          fi
        '';
      });
  })
