# hatter-example

The smallest complete [hatter](https://github.com/jappeace/hatter) app:
a greeting and a button that counts its taps, written in Haskell,
built into a native Android APK (and an iOS library) with Nix.

Clone this repository and use it as the starting point for your own
app. All the cross-compilation is done by hatter's nix code; this repo
only pins hatter and points it at `app/Main.hs`.

## Build and install (Android)

You need [Nix](https://nixos.org/download/) and, to install on a
phone, `adb` with USB debugging enabled on the device.

```bash
git clone https://github.com/jappeace/hatter-example
cd hatter-example
nix-build nix/apk.nix          # takes a long while the first time
adb install result/hatter-example.apk
```

Or run `./install.sh`, which builds, installs, launches the app and
tails its log output.

The first build cross-compiles GHC's libraries and hatter for both
arm64 and armv7; expect it to take a long time and download a lot.
Later builds only recompile `app/Main.hs`.

The pre-built binaries are served from `https://nix-cache.jappie.me`.
To use that cache locally, add to `/etc/nix/nix.conf` (or
`~/.config/nix/nix.conf`):

```
extra-substituters = https://nix-cache.jappie.me
extra-trusted-public-keys = nix-cache.jappie.me:WjkKcvFtHih2i+n7bdsrJ3HuGboJiU2hA2CZbf9I9oc=
```

## What is where

| Path | Purpose |
|---|---|
| `app/Main.hs` | The app. `main` builds a `MobileApp` and hands it to hatter. Edit this. |
| `default.nix` | Cross-compiles `app/Main.hs` to `libhatter.so` for one Android architecture. |
| `nix/apk.nix` | Builds the `.so` for both architectures and packages the APK. `nix-build nix/apk.nix` is the command you run. |
| `nix/native.nix` | Desktop typecheck of `app/Main.hs`, no cross-compile. Fast feedback. |
| `nix/ios.nix`, `nix/ios-app.nix` | iOS static library and staged Xcode project (macOS only). |
| `nix/ci.nix` | Everything the CI builds, `nix-build nix/ci.nix -A all-builds`. |
| `nix/sources/` | The pinned hatter and nixpkgs revisions, managed by [npins](https://github.com/andir/npins). |
| `android/` | Manifest, app name and the one-line `MainActivity`. Change the package name and `app_name` for your own app. |
| `hatter-example.cabal` | Only used by the desktop build and editor tooling; the mobile builds compile `app/Main.hs` directly. |

## Making it your own

1. Edit `app/Main.hs`. The widget vocabulary (`text`, `button`,
   `column`, `row`, text inputs, scroll views, images, ...) lives in
   [`Hatter.Widget`](https://hackage.haskell.org/package/hatter/docs/Hatter-Widget.html);
   the platform APIs (camera, bluetooth, HTTP, storage, ...) are the
   other `Hatter.*` modules. hatter's own `test/*DemoMain.hs` files
   show each of them in a self-contained app.
2. Rename the Java package: `android/AndroidManifest.xml`,
   `android/java/me/jappie/hatterexample/MainActivity.java` (and its
   directory), and `package=` in `install.sh`.
3. Extra Hackage dependencies: add them to `hatter-example.cabal` and
   pass `consumerCabalFile = ./hatter-example.cabal;` to `cross-deps.nix`
   in `default.nix` (see hatter's Readme, "Consumer projects"). This
   example only uses `base` and `text`, which hatter already ships.
4. More than one Haskell module: hatter compiles `Main.hs` one-shot,
   so extra modules must be copied in and linked explicitly. See
   `default.nix` in [kbeacon-ota-tool](https://github.com/jappeace/kbeacon-ota-tool)
   for the `--make` variant that does this.
5. Update hatter: `npins update hatter` (or edit
   `nix/sources/sources.json` by hand).

## Desktop typecheck

```bash
nix-build nix/native.nix
```

## iOS

On a Mac:

```bash
nix-build nix/ios.nix                        # device library
nix-build nix/ios.nix --arg simulator true   # simulator library
nix-build nix/ios-app.nix                    # staged Xcode project
```

See hatter's Readme, "Building for iOS", for wiring the staged project
into Xcode.
