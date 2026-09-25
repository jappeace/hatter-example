# iOS simulator app: stages hatter's Xcode project with the pre-built
# Haskell library. Output: $out/share/ios/ ready for xcodebuild.
#
# Usage (on a Mac): nix-build nix/ios-app.nix
{ sources ? import ./sources }:
let
  hatterLib = import "${sources.hatter}/nix/lib.nix" { inherit sources; };
  iosLib = import ./ios.nix { inherit sources; simulator = true; };
in
hatterLib.mkSimulatorApp {
  inherit iosLib;
  iosSrc = "${sources.hatter}/ios";
  name = "hatter-example-ios-simulator";
}
