# Desktop build: typechecks app/Main.hs against hatter's desktop C
# stubs. Fast feedback without a cross-compile; CI runs this first.
#
# Usage: nix-build nix/native.nix
{ sources ? import ./sources }:
let
  pkgs = import sources.nixpkgs {};
  # hatter's own haskellPackages overlay (hatter-project + unwitch).
  hpkgs = import "${sources.hatter}/nix/hpkgs.nix" {};
  exampleSrc = pkgs.lib.fileset.toSource {
    root = ../.;
    fileset = pkgs.lib.fileset.unions [
      ../app
      ../hatter-example.cabal
      ../LICENSE
    ];
  };
  extended = hpkgs.extend (self: _super: {
    hatter-example = self.callCabal2nix "hatter-example" exampleSrc {
      hatter = self.hatter-project;
    };
  });
in
extended.hatter-example
