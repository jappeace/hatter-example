# Cross-compile app/Main.hs to an Android shared library (libhatter.so).
#
# Usage:
#   nix-build default.nix                            # arm64-v8a (default)
#   nix-build default.nix --argstr androidArch armv7a
#
# You normally do not run this directly: nix/apk.nix imports it for
# both architectures and packages the result into an APK.
{ sources ? import ./nix/sources
, androidArch ? "aarch64"
}:
let
  hatterLib = import "${sources.hatter}/nix/lib.nix" { inherit sources androidArch; };
  # Filtered hatter source tree, so unrelated hatter files don't bust
  # the cross-compile cache.
  hatterSrc = import "${sources.hatter}/nix/hatter-src.nix" { inherit sources; };
  # hatter and its Hackage dependencies, cross-compiled for Android.
  # This app only needs base and text, which hatter already depends
  # on, so no consumer dependencies are declared. If your app needs
  # more packages, pass `consumerCabalFile = ./your-app.cabal;` here
  # (see hatter's Readme, "Consumer projects").
  crossDeps = import "${sources.hatter}/nix/cross-deps.nix" {
    inherit sources androidArch hatterSrc;
  };
in
hatterLib.mkAndroidLib {
  inherit hatterSrc crossDeps;
  pname = "hatter-example-android";
  mainModule = ./app/Main.hs;
}
