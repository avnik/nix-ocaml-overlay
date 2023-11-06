{lib, ...} @ a: {
  /*
  imports = [
    ./ocaml.nix
    ./merge-inputs.nix
  ];
  options.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = null;
  };
  config.flake.lib = config.lib;
  */
  flake.lib = (import ./ocaml.nix a).lib // (import ./merge-inputs.nix a).lib;
}
