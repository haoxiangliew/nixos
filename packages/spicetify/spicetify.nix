{ spotify-unwrapped, pkgs, lib, fetchFromGitHub, formats, spicetify-cli }:
let
  booleanToString = boolean: if boolean then "1" else "0";
  listToString = list: lib.concatStringsSep "|" list;

  # nix-shell -p nix-prefetch --run 'nix-prefetch fetchFromGitHub --owner spicetify --repo spicetify-themes --rev master'
  # dribbblish = "${
  #     fetchFromGitHub {
  #       owner = "spicetify";
  #       repo = "spicetify-themes";
  #       rev = "master";
  #       sha256 = "sha256-87afREB/TLqs4rObsDPG/PaM5A5keB3GbXTATWcqMN0=";
  #     }
  #   }/Dribbblish";

  # nix-shell -p nix-prefetch --run 'nix-prefetch fetchFromGitHub --owner catppuccin --repo spicetify --rev main'
  catppuccin = "${fetchFromGitHub {
    owner = "catppuccin";
    repo = "spicetify";
    rev = "main";
    sha256 = "sha256-yitiDqXZgX5NQlX66FW4YgS5fO2eF1W0QX5rKLD9uRE=";
  }}";

  configFile = (formats.ini { }).generate "config-xpui.ini" {
    Setting = {
      # current_theme = "Dribbblish";
      # color_scheme = "dracula";
      current_theme = "catppuccin-mocha";
      color_scheme = "mauve";
      overwrite_assets = booleanToString true;
      check_spicetify_upgrade = booleanToString false;
      prefs_path = "PREFS_PATH";
      spotify_path = "SPOTIFY_PATH";
      inject_css = booleanToString true;
      replace_colors = booleanToString true;
      spotify_launch_flags = listToString [ ];
    };

    Preprocesses = {
      disable_ui_logging = booleanToString true;
      remove_rtl_rule = booleanToString true;
      expose_apis = booleanToString true;
      disable_upgrade_check = booleanToString true;
      disable_sentry = booleanToString true;
    };

    AdditionalOptions = {
      # extensions = listToString [ "dribbblish.js" ];
      extensions = listToString [ "catppuccin-mocha.js" ];
      custom_apps = listToString [ ];
      sidebar_config = booleanToString true;
      home_config = booleanToString true;
      experimental_features = booleanToString true;
    };

    # Patch = {
    #   "xpui.js_find_8008" = ",(w+=)32,";
    #   "xpui.js_repl_8008" = ",\${1}56,";
    # };

    Backup = {
      version = "";
      "with" = "";
    };
  };

  deviceScaleFactor = null;

  version = "1.2.11.916.geb595a67";
  rev = "67";

  deps = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curlWithGnuTls
    dbus
    expat
    ffmpeg
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    libdrm
    libgcrypt
    libnotify
    libpng
    libpulseaudio
    libxkbcommon
    mesa
    nss
    pango
    stdenv.cc.cc
    systemd
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libxshmfence
    xorg.libXtst
    zlib
  ];

in spotify-unwrapped.overrideAttrs (oldAttrs: {

  version = "${version}";

  # curl -H 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/spotify | jq
  src = builtins.fetchurl {
    url =
      "https://api.snapcraft.io/api/v1/snaps/download/pOBIoZ2LrCB3rDohMxoYGnbN14EHOgD7_${rev}.snap";
    sha256 = "0a8dzj2j3wrcjvyib0pzlfw8nmkb3xrj3am0v2f4gm4sayhz5gmz";
  };

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ spicetify-cli ];

  # ln -s ${dribbblish}/dribbblish.js $spicetifyDir/Extensions/dribbblish.js
  # ln -s ${dribbblish} $spicetifyDir/Themes/Dribbblish

  installPhase = ''
    runHook preInstall

    libdir=$out/lib/spotify
    mkdir -p $libdir
    mv ./usr/* $out/

    cp meta/snap.yaml $out

    # Work around Spotify referring to a specific minor version of
    # OpenSSL.

    ln -s ${lib.getLib pkgs.openssl}/lib/libssl.so $libdir/libssl.so.1.0.0
    ln -s ${lib.getLib pkgs.openssl}/lib/libcrypto.so $libdir/libcrypto.so.1.0.0
    ln -s ${pkgs.nspr.out}/lib/libnspr4.so $libdir/libnspr4.so
    ln -s ${pkgs.nspr.out}/lib/libplc4.so $libdir/libplc4.so

    ln -s ${pkgs.ffmpeg.lib}/lib/libavcodec.so* $libdir
    ln -s ${pkgs.ffmpeg.lib}/lib/libavformat.so* $libdir

    rpath="$out/share/spotify:$libdir"

    patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $rpath $out/share/spotify/spotify

    librarypath="${lib.makeLibraryPath deps}:$libdir"
    wrapProgram $out/share/spotify/spotify \
      ''${gappsWrapperArgs[@]} \
      ${
        lib.optionalString (deviceScaleFactor != null) ''
          --add-flags "--force-device-scale-factor=${
            toString deviceScaleFactor
          }" \
        ''
      } \
      --prefix LD_LIBRARY_PATH : "$librarypath" \
      --prefix PATH : "${pkgs.gnome.zenity}/bin"

    # fix Icon line in the desktop file (#48062)
    sed -i "s:^Icon=.*:Icon=spotify-client:" "$out/share/spotify/spotify.desktop"

    # Desktop file
    mkdir -p "$out/share/applications/"
    cp "$out/share/spotify/spotify.desktop" "$out/share/applications/"

    # Icons
    for i in 16 22 24 32 48 64 128 256 512; do
      ixi="$i"x"$i"
      mkdir -p "$out/share/icons/hicolor/$ixi/apps"
      ln -s "$out/share/spotify/icons/spotify-linux-$i.png" \
        "$out/share/icons/hicolor/$ixi/apps/spotify-client.png"
    done

    runHook postInstall
  '';

  # cp -r ${dribbblish}/dribbblish.js $spicetifyDir/Extensions/dribbblish.js
  # cp -r ${dribbblish} $spicetifyDir/Themes/Dribbblish

  postInstall = (oldAttrs.postInstall or "") + ''
    export HOME=$TMP

    spicetifyDir=$(dirname "$(spicetify-cli -c)")

    cp -r ${catppuccin}/js/catppuccin-mocha.js $spicetifyDir/Extensions/catppuccin-mocha.js
    cp -r ${catppuccin}/catppuccin-mocha $spicetifyDir/Themes/catppuccin-mocha

    touch $out/prefs
    cp -f ${configFile} $spicetifyDir/config-xpui.ini

    # substituteInPlace $spicetifyDir/Themes/Dribbblish/color.ini \
    #   --replace "44475a" "22212C" \
    #   --replace "6272a4" "17161D" \
    #   --replace "ffb86c" "9580FF"

    substituteInPlace $spicetifyDir/config-xpui.ini \
      --replace "PREFS_PATH" "$out/prefs" \
      --replace "SPOTIFY_PATH" "$out/share/spotify"

    spicetify-cli backup apply
  '';
})
