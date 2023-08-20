{ config, pkgs, lib, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;
    firefox.enableGnomeExtensions = true;
    chromium.enableWideVine = true;
  };

  home.file.".mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source =
    "${pkgs.chrome-gnome-shell}/lib/mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";

  gtk = {
    enable = true;
    font = {
      name = "Cantarell";
      package = pkgs.cantarell-fonts;
      size = 11;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home = {
    stateVersion = lib.versions.majorMinor lib.version;
    packages = with pkgs; [
      # apps
      anki-bin
      bitwarden
      bottles
      croc
      darktable
      ffmpeg
      ffmpeg-normalize
      firebird-emu
      gimp
      gtypist
      inkscape
      libreoffice-fresh
      libsForQt5.kdenlive
      lieer
      masterpdfeditor
      notmuch
      obs-studio
      octaveFull
      piper
      # plex-mpv-shim
      qmk
      rbw
      rclone
      scrcpy
      speedtest-cli
      spotify
      (ventoy.override {
        defaultGuiType = "gtk3";
        withGtk3 = true;
      })
      via
      vial
      xournalpp
      yt-dlp
      yubikey-manager-qt
      zathura
      # zoom-us

      # games
      lutris

      # social
      armcord
      element-desktop
      signal-desktop
      teams

      # devtools
      criu
      fd
      fzf
      insomnia
      jq
      picocom
      ripgrep
      silver-searcher
      vagrant
      valgrind
      # ide
      arduino
      ghidra
      # kicad
      # c / c++
      avrdude
      catch2
      clang
      clang-tools
      cmake-language-server
      cmakeWithGui
      dfu-util
      # gcc-arm-embedded
      gcovr
      gdb
      gnumake
      lcov
      libllvm
      ninja
      pkgsCross.avr.buildPackages.binutils
      pkgsCross.avr.buildPackages.gcc
      # css
      nodePackages.vscode-css-languageserver-bin
      # git
      gitAndTools.delta
      # go
      go
      gopls
      # html
      nodePackages.vscode-html-languageserver-bin
      # java
      jdk
      # latex
      pandoc
      texlive.combined.scheme-medium
      # markdown
      marksman
      # nix
      direnv
      hydra-check
      nix-prefetch
      nix-tree
      # nodejs
      nodejs
      # pascal
      fpc
      # python
      black
      pythonWithMyPackages
      nodePackages.pyright
      # rust
      (fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      rust-analyzer-nightly
      # verilog
      verible
    ];
  };

  programs = {
    chromium = {
      enable = true;
      package = (pkgs.google-chrome-dev.override {
        commandLineArgs = [
          "--force-dark-mode"
          "--ozone-platform-hint=x11"
          "--enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder,VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks"
          "--disable-features=UseChromeOSDirectVideoDecoder,UseSkiaRenderer"
        ];
      });
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-bin;
      profiles = let
        defaultSettings = {
          "extensions.pocket.enabled" = false;
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;
          "network.trr.disable-ECS" = false;
        };
      in {
        default = {
          id = 0;
          path = "0.default";
          settings = defaultSettings;
        };
      };
    };
    emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
      extraPackages = (epkgs: [ epkgs.vterm ]);
    };
    vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (ps: with ps; [ ]);
    };
  };

  xdg = {
    configFile = {
      "nixpkgs/config.nix".text = ''
        {
          allowUnfree = true;
          # python2 nix-shell
          # permittedInsecurePackages = [
          #   "python-2.7.18.6"
          # ];
        }
      '';
      "mpv/input.conf".source = ../config/mpv/input.conf;
      "mpv/mpv.conf".source = ../config/mpv/mpv.conf;
      "mpv/scripts/mpv-gnome-inhibit.lua".source =
        ../config/mpv/mpv-gnome-inhibit.lua;
      "plex-mpv-shim/input.conf".source = ../config/mpv/input.conf;
      "plex-mpv-shim/mpv.conf".source = ../config/mpv/mpv.conf;
      "ranger/rc.conf".source = ../config/ranger/rc.conf;
    };
  };
}
