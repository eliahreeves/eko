{
  lib,
  flutter,
  gtk3,
  glib,
  jsoncpp,
  openssl,
  libsecret,
  copyDesktopItems,
  wrapGAppsHook3,
  pkg-config,
  cmake,
  jq,
  yq-go,
  makeDesktopItem,
}:
flutter.buildFlutterApplication {
  pname = "eko";
  version = "2.0.0";
  src = lib.cleanSource ../eko_app;
  autoPubspecLock = ../eko_app/pubspec.lock;
  gitHashes = {
    webcrypto = "sha256-XkZe7LcVyUtUJoTqeyd87xLENJIIExgyI9lym/aQBtw=";
  };
  vendorHash = lib.fakeHash;
  dontUseCmakeConfigure = true;

  buildInputs = [
    gtk3
    glib
    jsoncpp
    openssl
    libsecret
  ];

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook3
    pkg-config
    cmake
    jq
    yq-go
  ];

  preBuild = ''
    yq -i '.flutter.fonts += [{"family":"Inter","fonts":[{"asset":"fonts/linux/Inter-Cleaned.ttf"},{"asset":"fonts/linux/Inter-Italic-Cleaned.ttf"}]},{"family":"NotoEmoji","fonts":[{"asset":"fonts/linux/NotoColorEmoji.ttf"}]}]' pubspec.yaml

    webcrypto_root_uri="$(jq -r '.packages[] | select(.name=="webcrypto") | .rootUri' .dart_tool/package_config.json)"
    if [ -z "$webcrypto_root_uri" ] || [ "$webcrypto_root_uri" = "null" ]; then
      echo "webcrypto package not found in package_config.json"
      exit 1
    fi

    webcrypto_root="''${webcrypto_root_uri#file://}"
    cmake -S "$webcrypto_root/src" -B .dart_tool/webcrypto
    cmake --build .dart_tool/webcrypto --target webcrypto
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/app/eko/lib"
    )
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "com.eko.network";
      desktopName = "eko";
      comment = "eko social media network";
      exec = "eko";
      icon = "eko-app";
      categories = ["Network"];
    })
  ];

  postInstall = ''
    install -Dm644 "$src/linux/assets/logo.svg" "$out/share/icons/hicolor/scalable/apps/eko-app.svg"
    if [ -f "build/native_assets/linux/libwebcrypto.so" ]; then
      install -Dm755 "build/native_assets/linux/libwebcrypto.so" "$out/app/eko/lib/libwebcrypto.so"
    else
      echo "libwebcrypto.so not found at build/native_assets/linux" >&2
      exit 1
    fi
  '';

  meta = {
    platforms = lib.platforms.linux;
  };
}
