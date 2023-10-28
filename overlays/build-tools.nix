{
  self,
  inputs,
  ...
}: let
  inherit (self.lib) liftOCamlOverlay';
in
  liftOCamlOverlay' ({
    ...
  }: {
  })
