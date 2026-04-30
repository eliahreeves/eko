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
  makeDesktopItem,
}:
flutter.buildFlutterApplication {
  pname = "eko";
  version = "2.0.0";
  src = lib.cleanSource ../eko_app;
  autoPubspecLock = ../eko_app/pubspec.lock;
  gitHashes = {};
  vendorHash = lib.fakeHash;

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
  ];

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
  '';

  meta = {
    platforms = lib.platforms.linux;
  };
}
