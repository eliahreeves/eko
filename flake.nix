{
  description = "Flutter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {system, ...}: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
        };

        devShells.default =
          if inputs.nixpkgs.legacyPackages.${system}.stdenv.isDarwin
          then
            let
              pkgs = import inputs.nixpkgs {
                inherit system;
              };

              flutterDarwin = pkgs.flutter.override {
                supportedTargetFlutterPlatforms = [
                  "universal"
                  "web"
                  "macos"
                  "ios"
                ];
              };
            in
              pkgs.mkShellNoCC {
                nativeBuildInputs = with pkgs; [
                  flutterDarwin
                  jdk
                  ninja
                  unzip
                  firebase-tools
                  go
                  google-cloud-sdk
                ];

                shellHook = ''
                  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
                  export PATH=/usr/bin:/bin:/usr/sbin:/sbin:$PATH
                  unset CC CXX LD AR NM RANLIB STRIP SDKROOT CPATH LIBRARY_PATH CFLAGS CXXFLAGS LDFLAGS OBJCFLAGS OBJCXXFLAGS

                  export FLUTTER_ROOT_LOCAL="$HOME/.cache/flutter-sdk-nix-${pkgs.flutter.version}"
                  if [ ! -x "$FLUTTER_ROOT_LOCAL/bin/flutter" ]; then
                    mkdir -p "$FLUTTER_ROOT_LOCAL"
                    /usr/bin/rsync -aL --delete --chmod=Du+rwx,Dgo+rx,Fu+rwX,Fgo+rX "${flutterDarwin}/" "$FLUTTER_ROOT_LOCAL/"
                  fi

                  chmod -R u+w "$FLUTTER_ROOT_LOCAL/bin/cache/artifacts/engine" 2>/dev/null || true

                  export FLUTTER_ROOT="$FLUTTER_ROOT_LOCAL"
                  export PATH="$FLUTTER_ROOT/bin:$PATH"

                  git config core.hooksPath scripts/git-hooks
                '';
              }
          else
            let
              pkgs = import inputs.nixpkgs {
                inherit system;
                config = {
                  android_sdk.accept_license = true;
                  allowUnfree = true;
                };
              };

              androidComposition = pkgs.androidenv.composeAndroidPackages {
                buildToolsVersions = ["35.0.0"];
                platformVersions = [36 35 34 33 31];
                includeNDK = true;
                ndkVersions = ["27.0.12077973"];
                includeCmake = true;
                cmakeVersions = ["3.22.1"];
              };

              androidSdk = androidComposition.androidsdk;
              sdkPath = "${androidSdk}/libexec/android-sdk";
            in
              pkgs.mkShell {
                ANDROID_SDK_ROOT = sdkPath;
                ANDROID_HOME = sdkPath;

                nativeBuildInputs = with pkgs; [
                  flutter
                  androidSdk
                  jdk
                  ninja
                  unzip
                  firebase-tools
                  go
                  google-cloud-sdk
                ];

                shellHook = ''
                  export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdkPath}/build-tools/35.0.0/aapt2"
                  git config core.hooksPath scripts/git-hooks
                '';
              };
      };
    };
}
