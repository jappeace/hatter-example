# iOS static library, built via hatter's lib.nix (macOS only).
#
# Usage (on a Mac):
#   nix-build nix/ios.nix                        # device
#   nix-build nix/ios.nix --arg simulator true   # simulator
{ sources ? import ./sources
, simulator ? false
}:
let
  hatterSrc = import "${sources.hatter}/nix/hatter-src.nix" { inherit sources; };
  hatterLib = import "${sources.hatter}/nix/lib.nix" { inherit sources; };
  iosDeps = import "${sources.hatter}/nix/ios-deps.nix" { inherit sources; };
in
hatterLib.mkIOSLib {
  inherit hatterSrc simulator;
  pname = "hatter-example-ios";
  mainModule = ../app/Main.hs;
  crossDeps = iosDeps;
}
