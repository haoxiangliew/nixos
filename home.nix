# Hao Xiang's nixos-unstable home configuration

{ config, pkgs, lib, ... }:

with pkgs;
let

  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  masterPkgs = import (builtins.fetchTarball
    "https://github.com/nixos/nixpkgs/archive/master.tar.gz") {
      config = config.nixpkgs.config;
    };
  lieerPkgs = import (builtins.fetchTarball
    "https://github.com/archer-65/nixpkgs/archive/refs/heads/update/lieer.tar.gz") {
      config = config.nixpkgs.config;
    };
  emacsPinnedPkgs = import (builtins.fetchTarball {
    url =
      "https://github.com/nixos/nixpkgs/archive/d30264c2691128adc261d7c9388033645f0e742b.tar.gz";
  }) {
    config = config.nixpkgs.config;
    overlays = [
      (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/emacs-overlay/archive/8f327ba75dc95080ffab59a4f68b2c73b52d3cb3.tar.gz";
      }))
    ];
  };

in {
  imports = [ (import "${home-manager}/nixos") ./environments/gnome-home.nix ];

  nix = {
    settings = {
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  nixpkgs = {
    overlays = let
      moz-rev = "master";
      moz-url = builtins.fetchTarball {
        url =
          "https://github.com/mozilla/nixpkgs-mozilla/archive/${moz-rev}.tar.gz";
      };
      firefoxOverlay = (import "${moz-url}/firefox-overlay.nix");
      fenix-url = builtins.fetchTarball {
        url = "https://github.com/nix-community/fenix/archive/main.tar.gz";
      };
      rustOverlay = (import "${fenix-url}/overlay.nix");
      armcordVersion = "3.2.0";
      armcordOverlay = (self: super: {
        armcord = super.armcord.overrideAttrs (oldAttrs: {
          version = "${armcordVersion}";
          src = builtins.fetchurl
            "https://build.armcord.xyz/dev/v21.4.4/ArmCord_${armcordVersion}_amd64.deb";
          sha256 = "0yb4gmjhsajfcpjcfxz3ld8n3v5s2sp9frkgf92bicf17gi2cnpr";
        });
      });
      openasar = builtins.fetchurl {
        url =
          "https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar";
        sha256 = "0di54lgqj5lscwi2pdaifpqjfkqjbzk1r0bgvhffl2bap94rm5bw";
      };
      discordOverlay = (self: super: {
        discord = super.discord.overrideAttrs (oldAttrs: {
          src = builtins.fetchTarball
            "https://discord.com/api/download?platform=linux&format=tar.gz";
          installPhase = (oldAttrs.installPhase or "") + ''
            echo "Replacing app.asar with OpenAsar..."
            cp -r ${openasar} $out/opt/Discord/resources/app.asar
          '';
        });
      });
      emacsOverlay = (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
      }));
      neovimOverlay = (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
      }));
      draculaThemeOverlay = (self: super: {
        dracula-theme = super.dracula-theme.overrideAttrs (oldAttrs: {
          src = builtins.fetchTarball
            "https://github.com/dracula/gtk/archive/master.tar.gz";
          installPhase = (oldAttrs.installPhase or "") + ''
            rm $out/share/themes/Dracula/gnome-shell/gnome-shell.css
            rm $out/share/themes/Dracula/gnome-shell/gnome-shell.scss
            rm $out/share/themes/Dracula/gnome-shell/_common.scss
            cp -a gnome-shell/v40/* $out/share/themes/Dracula/gnome-shell
          '';
        });
      });
      lutrisOverlay = (self: super: {
        lutris = super.lutris.overrideAttrs (oldAttrs: {
          extraPkgs = (oldAttrs.extraPkgs or [ ]) ++ [ pkgs.xorg.libXtst ];
          propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ])
            ++ [ pkgs.python3Packages.pypresence ];
        });
      });
      masterPdfVersion = "5.9.40";
      masterPdfOverlay = (self: super: {
        masterpdfeditor = super.masterpdfeditor.overrideAttrs (oldAttrs: {
          src = builtins.fetchurl {
            url =
              "https://code-industry.net/public/master-pdf-editor-${masterPdfVersion}-qt5.x86_64.tar.gz";
            sha256 = "1f654d4afgq68v1nj856afi0xpy33z861bf2apzcl4kh58xmvzlr";
          };
          version = "${masterPdfVersion}";
          desktopFile = pkgs.writeText "masterpdfeditor5.desktop" ''
            [Desktop Entry]
            Name=Master PDF Editor 5
            Comment=Edit PDF files
            Exec=/opt/master-pdf-editor-5/masterpdfeditor5 %f
            Path=/opt/master-pdf-editor-5
            Terminal=false
            Icon=/opt/master-pdf-editor-5/masterpdfeditor5.png
            Type=Application
            Categories=Office;Graphics;
            MimeType=application/pdf;application/x-bzpdf;application/x-gzpdf;
          '';
          installPhase = ''
            runHook preInstall
            p=$out/opt/masterpdfeditor
            mkdir -p $out/bin
            echo "Unlocking..."
            ${pkgs.perl}/bin/perl -pi -e 's/(\xE8...\xFF)\x88(..\xBF\x30)/$1\xFE$2/g' masterpdfeditor5
            echo "Unlocked!"
            cp $desktopFile masterpdfeditor5.desktop
            substituteInPlace masterpdfeditor5.desktop \
              --replace 'Exec=/opt/master-pdf-editor-5' "Exec=$out/bin" \
              --replace 'Path=/opt/master-pdf-editor-5' "Path=$out/bin" \
              --replace 'Icon=/opt/master-pdf-editor-5' "Icon=$out/share/pixmaps"
            install -Dm644 -t $out/share/pixmaps      masterpdfeditor5.png
            install -Dm644 -t $out/share/applications masterpdfeditor5.desktop
            install -Dm755 -t $p                      masterpdfeditor5
            # install -Dm644 license.txt $out/share/$name/LICENSE
            ln -s $p/masterpdfeditor5 $out/bin/masterpdfeditor5
            cp -v -r stamps templates lang fonts $p
            runHook postInstall
          '';
        });
      });
      pythonPackages = python-packages:
        with python-packages; [
          aioconsole
          bleak
          catppuccin
          matplotlib
          openpyxl
          pandas
          pygame
          # pygame-gui
          regex
          tkinter
        ];
      pythonOverlay = (self: super: {
        pythonWithMyPackages = super.python3.withPackages pythonPackages;
      });
      spicetify-src = builtins.fetchTarball
        "https://github.com/spicetify/spicetify-cli/archive/master.tar.gz";
      spicetifyOverlay = (self: super: {
        spicetify-cli = super.spicetify-cli.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            cp -r ${spicetify-src}/css-map.json $out/bin/css-map.json
          '';
        });
        spotify-unwrapped =
          super.callPackage ./packages/spicetify/spicetify.nix {
            inherit (super) spotify-unwrapped;
          };
      });
      ventoyVersion = "1.0.91";
      ventoyOverlay = (self: super: {
        ventoy = super.ventoy.overrideAttrs (old: {
          version = "${ventoyVersion}";
          src = builtins.fetchurl {
            url =
              "https://github.com/ventoy/Ventoy/releases/download/v${ventoyVersion}/ventoy-${ventoyVersion}-linux.tar.gz";
            sha256 =
              "f6fb0574ec6c5b50acd3a8153ef42eb23bb6fb0a783e90706c7654ba0c1bddca";
          };
        });
      });
      xournalppOverlay = (self: super: {
        xournalpp = super.xournalpp.overrideAttrs (oldAttrs: {
          src = builtins.fetchTarball
            "https://github.com/xournalpp/xournalpp/archive/refs/tags/nightly.tar.gz";
          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.alsa-lib ];
        });
      });
      packagesOverlay = (final: prev: {
        catppuccin-gtk-mocha = prev.callPackage ./packages/catppuccin-gtk { };
        # quartus-prime-lite = prev.callPackage ./packages/quartus-prime { };
        spotify = prev.callPackage ./packages/spotify { };
      });
    in [
      masterPdfOverlay
      pythonOverlay
      rustOverlay
      spicetifyOverlay
      ventoyOverlay
      xournalppOverlay
      packagesOverlay
    ];
  };

  environment = {
    variables = {
      EDITOR = "mg";
      FZF_DEFAULT_COMMAND =
        "fd --type file --color=always --strip-cwd-prefix --hidden --exclude .git";
      FZF_DEFAULT_OPTS = "--ansi";
    };
  };
  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock-origin
      "dcpihecpambacapedldabdbpakmachpb;https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml" # bypass-paywalls
      "gfolbeacfbanmnohmnppjgenmmajffop;https://younesaassila.github.io/ttv-lol-pro/updates.xml" # ttv-lol-pro
    ];
  };

  home-manager.users.haoxiangliew = {

    # home.stateVersion = config.system.nixos.release;
    home.stateVersion = "23.05";

    nixpkgs = {
      config = {
        allowUnfree = true;
        firefox.enableGnomeExtensions = true;
        chromium.enableWideVine = true;
      };
    };

    home.file.".mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source =
      "${pkgs.chrome-gnome-shell}/lib/mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";

    gtk = {
      enable = true;
      font = {
        name = "Ubuntu";
        package = pkgs.ubuntu_font_family;
        size = 11;
      };
      cursorTheme = {
        name = "Catppuccin-Mocha-Dark-Cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
        size = 8;
      };
      theme = {
        name = "Catppuccin-Mocha-Standard-Mauve-Dark";
        package = catppuccin-gtk-mocha;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };

    home.file.".icons/default/cursors".source =
      "${catppuccin-cursors.mochaDark}/share/icons/Catppuccin-Mocha-Dark-Cursors/cursors";

    home.pointerCursor = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 8;
      x11.enable = true;
      gtk.enable = true;
    };

    home.packages = with pkgs; [
      # apps
      bitwarden
      bottles
      darktable
      ffmpeg
      ffmpeg-normalize
      firebird-emu
      galaxy-buds-client
      gimp
      gtypist
      inkscape
      libreoffice-fresh
      libsForQt5.kdenlive
      lieerPkgs.lieer
      masterpdfeditor
      notmuch
      obs-studio
      octaveFull
      # play-with-mpv
      plex-mpv-shim
      qmk
      rbw
      rclone
      scrcpy
      speedtest-cli
      spotify-unwrapped
      (ventoy.override {
        defaultGuiType = "gtk3";
        withGtk3 = true;
      })
      via
      vial
      xournalpp
      yt-dlp
      zathura
      zoom-us

      # games
      lutris

      # social
      element-desktop
      signal-desktop

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
      kicad
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
      lua53Packages.digestif
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

    programs = {
      chromium = {
        enable = true;
        package = (pkgs.google-chrome.override {
          commandLineArgs = [
            "--force-dark-mode"
            "--enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder"
            "--disable-features=UseChromeOSDirectVideoDecoder"
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
        # package = emacsPinnedPkgs.emacsPgtk;
        package = pkgs.emacs-gtk;
        extraPackages = (epkgs: [ epkgs.jinx epkgs.vterm ]);
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
            permittedInsecurePackages = [
              "python-2.7.18.6"
            ];
          }
        '';
        "mpv/input.conf".source = ./dotfiles/mpv/input.conf;
        "mpv/mpv.conf".source = ./dotfiles/mpv/mpv.conf;
        "mpv/scripts/mpv-gnome-inhibit.lua".source =
          ./dotfiles/mpv/mpv-gnome-inhibit.lua;
        "plex-mpv-shim/input.conf".source = ./dotfiles/mpv/input.conf;
        "plex-mpv-shim/mpv.conf".source = ./dotfiles/mpv/mpv.conf;
        "ranger/rc.conf".source = ./dotfiles/ranger/rc.conf;
      };
    };
  };
}
