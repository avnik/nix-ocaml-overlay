{
  inputs,
  self,
  ...
}: let
  overlays = {
    trunk = import ./trunk.nix {inherit self inputs;};
    native = import ./native.nix {inherit self inputs;};
    compiler = import ./compiler.nix {inherit self inputs;};
    findlib = import ./findlib.nix {inherit self inputs;};
    dune = import ./dune.nix {inherit self inputs;};
    build-tools = import ./build-tools.nix {inherit self inputs;};
    cross-fixes = import ./cross-fixes.nix {inherit self inputs;};
    packages = import ./packages.nix {inherit self inputs;};
    updates = import ./updates.nix {inherit self inputs;};
  };
  composeExtensions = f: g: final: prev: let
    fApplied = f final prev;
    prev' = prev // fApplied;
  in
    fApplied // g final prev';
  /*
  OO = config.orderedOverlays;
  overlays = builtins.map (x: x.overlay) OO;
  ordered' = lib.toposort (l: r: lib.elem r.name (l.requires or [])) (lib.mapAttrsToList (name: attrs: { inherit name; } // attrs) OO);
  ordered = if ordered' ? "cycle"
            then throw "Cycle detected: ${lib.generators.toPretty {} ordered'}"
            else let
                rev = lib.reverseList ordered'.result;
                in
                  builtins.trace "Overlay order: ${lib.concatMapStringsSep ", " (x: x.name) rev}" (builtins.map (x: x.overlay) rev);
  */

  ordered = with overlays; [
    trunk
    native
    compiler
    findlib
#    dune
    build-tools
    cross-fixes
    updates
    packages
  ];
  combined = builtins.foldl' composeExtensions (_: _: {}) ordered;
in {
  imports = [
  ];
  flake.overlays = overlays // {inherit combined;};
}
