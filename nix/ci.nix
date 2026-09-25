# CI entry point.
#
#   nix-build nix/ci.nix -A all-builds   # everything CI compiles
#   nix-build nix/ci.nix -A native       # desktop typecheck only
#   nix-build nix/ci.nix -A apk          # the Android APK
{ sources ? import ./sources }:
let
  isDarwin = builtins.currentSystem == "aarch64-darwin"
          || builtins.currentSystem == "x86_64-darwin";
  pkgs = import sources.nixpkgs {};

  buildTargets = {
    native = import ./native.nix { inherit sources; };
    android-aarch64 = import ../default.nix { inherit sources; };
    android-armv7a = import ../default.nix { inherit sources; androidArch = "armv7a"; };
    apk = import ./apk.nix { inherit sources; };
  } // (if isDarwin then {
    ios-lib = import ./ios.nix { inherit sources; };
    ios-simulator = import ./ios.nix { inherit sources; simulator = true; };
    ios-app = import ./ios-app.nix { inherit sources; };
  } else {});
in
buildTargets // {
  all-builds = pkgs.runCommand "ci-all-builds" {} ''
    mkdir -p $out
    ${builtins.concatStringsSep "\n" (
      builtins.map (name: "ln -s ${buildTargets.${name}} $out/${name}")
        (builtins.attrNames buildTargets)
    )}
  '';
}
