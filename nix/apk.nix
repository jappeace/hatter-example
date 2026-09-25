# Multi-arch Android APK: arm64-v8a (phones) + armeabi-v7a (Wear OS).
#
# Usage: nix-build nix/apk.nix
# Result: result/hatter-example.apk
{ sources ? import ./sources }:
let
  hatterLib     = import "${sources.hatter}/nix/lib.nix" { inherit sources; };
  sharedAarch64 = import ../default.nix { inherit sources; androidArch = "aarch64"; };
  sharedArmv7a  = import ../default.nix { inherit sources; androidArch = "armv7a"; };
in
hatterLib.mkApk {
  sharedLibs = [
    { lib = sharedAarch64; abiDir = "arm64-v8a"; }
    { lib = sharedArmv7a;  abiDir = "armeabi-v7a"; }
  ];
  # Our manifest, resources and MainActivity (package me.jappie.hatterexample).
  androidSrc  = ../android;
  # HatterActivity, the JNI base class, comes from hatter itself.
  baseJavaSrc = "${sources.hatter}/android/java";
  apkName     = "hatter-example.apk";
  name        = "hatter-example-apk";
}
