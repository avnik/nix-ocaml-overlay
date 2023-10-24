## Nixpkgs+ocaml cross build overlay and playground

Simplified cross-environment for build problematic packages (which don't cross build cleanly)

## How to build/debug

```sh
# nix build ".#crossed" -L --cores 16 -j 1
```
