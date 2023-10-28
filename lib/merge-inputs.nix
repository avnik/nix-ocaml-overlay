{lib, ...}: let
  __mergeInputs = acc: names: attrs: let
    ret =
      lib.foldl' (acc: x: acc // {"${x.name}" = x;})
      {}
      (builtins.concatMap
        (name:
          builtins.filter
          lib.isDerivation
          (lib.concatLists (lib.catAttrs name attrs)))
        names);
  in
    if ret == {}
    then acc
    else __mergeInputs (acc // ret) names (lib.attrValues ret);
in {
  lib = {
    mergeInputs = names: attrs: let
      acc = __mergeInputs {} names [attrs];
    in
      lib.attrValues acc;
  };
}
