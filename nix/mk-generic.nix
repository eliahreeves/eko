{pkgs}: {
  app,
  pname,
  version,
}:
pkgs.stdenv.mkDerivation {
  name = "${pname}-generic-linux-${version}";
  nativeBuildInputs = [pkgs.patchelf pkgs.gnutar pkgs.gzip];
  dontUnpack = true;
  dontPatchELF = true;
  dontBuild = true;
  installPhase = ''
    staging_dir="${pname}-linux-${version}"
    release_root="$staging_dir/${pname}"
    mkdir -p "$release_root"

    cp -R ${app}/app/${pname}/* "$release_root/"
    cp -r ${app}/share "$staging_dir/"

    if [ -f "${app}/build/native_assets/linux/libwebcrypto.so" ]; then
      cp "${app}/build/native_assets/linux/libwebcrypto.so" "$release_root/lib/"
    fi


    chmod -R +w "$staging_dir"

    # --- UN-NIXIFY ---
    patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 "$release_root/${pname}"
    patchelf --set-rpath '$ORIGIN/lib' "$release_root/${pname}"

    if [ -d "$release_root/lib" ]; then
      find "$release_root/lib" -name "*.so" -exec patchelf --set-rpath '$ORIGIN' {} \;
    fi

    # --- INSTALLER SCRIPT ---
    cat > "$staging_dir/install.sh" <<EOF
      #!/usr/bin/env bash
      set -euo pipefail

      PREFIX="\''${1:-\$HOME/.local}"
      BIN_DIR="\$PREFIX/bin"
      OPT_DIR="\$PREFIX/opt/${pname}"

      if [ "\$PREFIX" = "\$HOME/.local" ]; then
        SHARE_DIR="\''${XDG_DATA_HOME:-\$HOME/.local/share}"
      else
        SHARE_DIR="\$PREFIX/share"
      fi

      DESKTOP_DIR="\$SHARE_DIR/applications"
      ICON_DIR="\$SHARE_DIR/icons/hicolor/scalable/apps"

      echo "Installing ${pname} to \$PREFIX..."
      mkdir -p "\$OPT_DIR" "\$BIN_DIR" "\$DESKTOP_DIR" "\$ICON_DIR"

      cp -R "\$(dirname "\$0")/${pname}/." "\$OPT_DIR/"

      # Install icons
      ICON_SRC_DIR="\$(dirname "\$0")/share/icons/hicolor/scalable/apps"
      if [ -d "\$ICON_SRC_DIR" ]; then
        cp "\$ICON_SRC_DIR"/*.svg "\$ICON_DIR/" 2>/dev/null || true
      fi

      cat > "\$BIN_DIR/${pname}" <<EOSH
        #!/usr/bin/env bash
        exec "\$OPT_DIR/${pname}" "\\\$@"
      EOSH
      chmod +x "\$BIN_DIR/${pname}"

      # Install desktop file with absolute path
      DESKTOP_SRC=\$(find "\$(dirname "\$0")/share/applications" -name "*.desktop" -print -quit)
      if [ -n "\$DESKTOP_SRC" ]; then
        DESKTOP_NAME=\$(basename "\$DESKTOP_SRC")
        sed "s|^Exec=.*|Exec=\$BIN_DIR/${pname}|" "\$DESKTOP_SRC" > "\$DESKTOP_DIR/\$DESKTOP_NAME"
      fi

      if [ "\$PREFIX" = "\$HOME/.local" ]; then
          if command -v update-desktop-database >/dev/null 2>&1; then
              update-desktop-database "\$DESKTOP_DIR"
          fi
      fi
      echo "Installed to \$PREFIX. You can launch with '${pname}'."
    EOF
    chmod +x "$staging_dir/install.sh"

    mkdir -p $out
    tar -czf "$out/${pname}-linux-${version}.tar.gz" "$staging_dir"
  '';
}
