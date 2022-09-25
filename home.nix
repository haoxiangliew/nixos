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
  cmakeFix = import (builtins.fetchTarball {
    url =
      "https://github.com/NixOS/nixpkgs/archive/73994921df2b89021c1cbded66e8f057a41568c1.tar.gz";
  }) { config = config.nixpkgs.config; };
  emacsPinnedPkgs = import (builtins.fetchTarball {
    url =
      "https://github.com/nixos/nixpkgs/archive/f677051b8dc0b5e2a9348941c99eea8c4b0ff28f.tar.gz";
  }) {
    config = config.nixpkgs.config;
    overlays = [
      (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/emacs-overlay/archive/8ff1524472abef7c86c9e9c221d8969911074b4a.tar.gz";
      }))
    ];
  };
in {
  imports = [ (import "${home-manager}/nixos") ./environments/i3-home.nix ];

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
      nightlyOverlay = (import "${moz-url}/firefox-overlay.nix");
      openasar = builtins.fetchurl {
        url =
          "https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar";
        sha256 = "0qplzbvzjszxnw9fgl3klzp9ja1qj1wpd5f5jkxwaaxv6d3db0pi";
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
      draculaThemeOverlay = (self: super: {
        dracula-theme = super.dracula-theme.overrideAttrs (oldAttrs: {
          installPhase = (oldAttrs.installPhase or "") + ''
            rm $out/share/themes/Dracula/gnome-shell/gnome-shell.css
            rm $out/share/themes/Dracula/gnome-shell/gnome-shell.scss
            rm $out/share/themes/Dracula/gnome-shell/_common.scss
            cp -a gnome-shell/v40/* $out/share/themes/Dracula/gnome-shell
          '';
        });
      });
      lieerOverlay = (self: super: {
        lieer = super.lieer.overrideAttrs (_: {
          src = builtins.fetchTarball
            "https://github.com/gauteh/lieer/archive/11c792fbf416aedb0466f64973e29e1f4aed4916.tar.gz";
        });
      });
      lutrisOverlay = (self: super: {
        lutris = super.lutris.overrideAttrs (oldAttrs: {
          extraPkgs = (oldAttrs.extraPkgs or [ ]) ++ [ pkgs.xorg.libXtst ];
          propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ])
            ++ [ pkgs.python3Packages.pypresence ];
        });
      });
      masterPdfOverlay = (self: super: {
        masterpdfeditor = super.masterpdfeditor.overrideAttrs (oldAttrs: {
          # src = builtins.fetchTarball
          #   "https://web.archive.org/web/20201119203557/https://code-industry.net/public/master-pdf-editor-5.6.49-qt5.x86_64.tar.gz";
          installPhase = ''
            runHook preInstall
            p=$out/opt/masterpdfeditor
            mkdir -p $out/bin
            echo "Unlocking..."
            ${pkgs.perl}/bin/perl -pi -e 's/(\xE8...\xFF)\x88(..\xBF\x30)/$1\xFE$2/g' masterpdfeditor5
            echo "Unlocked!"
            substituteInPlace masterpdfeditor5.desktop \
              --replace 'Exec=/opt/master-pdf-editor-5' "Exec=$out/bin" \
              --replace 'Path=/opt/master-pdf-editor-5' "Path=$out/bin" \
              --replace 'Icon=/opt/master-pdf-editor-5' "Icon=$out/share/pixmaps"
            install -Dm644 -t $out/share/pixmaps      masterpdfeditor5.png
            install -Dm644 -t $out/share/applications masterpdfeditor5.desktop
            install -Dm755 -t $p                      masterpdfeditor5
            install -Dm644 license.txt $out/share/$name/LICENSE
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
          matplotlib
          pygame
          pygame-gui
          regex
        ];
      pythonOverlay = (self: super: {
        pythonWithMyPackages = super.python3.withPackages pythonPackages;
      });
      spicetify-src = builtins.fetchTarball
        "https://github.com/spicetify/spicetify-cli/archive/master.tar.gz";
      spicetifyOverlay = (self: super: {
        spicetify-cli = super.spicetify-cli.overrideAttrs (old: {
          version = "2.9.9";
          src = builtins.fetchTarball
            "https://github.com/spicetify/spicetify-cli/archive/refs/tags/v2.9.9.tar.gz";
          postInstall = (old.postInstall or "") + ''
            cp -r ${spicetify-src}/css-map.json $out/bin/css-map.json
          '';
        });
        spotify-unwrapped =
          super.callPackage ./packages/spicetify/spicetify.nix {
            inherit (super) spotify-unwrapped;
          };
      });
      viaAppOverlay = (self: super: {
        via = super.makeDesktopItem {
          name = "VIA";
          desktopName = "VIA";
          exec = ''
            ${google-chrome}/bin/google-chrome-stable --app="https://usevia.app" --use-gl=desktop --force-dark-mode --enable-accelerated-video-decode --enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder --disable-features=UseChromeOSDirectVideoDecoder'';
          terminal = false;
          type = "Application";
          icon = "via";
          comment = "Yet another keyboard configurator";
          categories = [ "Development" ];
        };
      });
      packagesOverlay = (final: prev: {
        marksman = prev.callPackage ./packages/marksman { };
        wechat-uos = prev.callPackage ./packages/wechat-uos { };
        quartus-prime-lite = prev.callPackage ./packages/quartus-prime { };
        hhkb-gnu = prev.callPackage ./packages/happy-hacking-gnu { };
      });
    in [
      discordOverlay
      draculaThemeOverlay
      lieerOverlay
      lutrisOverlay
      masterPdfOverlay
      nightlyOverlay
      pythonOverlay
      spicetifyOverlay
      viaAppOverlay
      packagesOverlay
    ];
  };

  home-manager.users.haoxiangliew = {

    home = { stateVersion = config.system.nixos.release; };

    nixpkgs = { config = { allowUnfree = true; }; };

    gtk = {
      enable = true;
      font = {
        name = "Ubuntu";
        package = pkgs.ubuntu_font_family;
      };
      cursorTheme = {
        name = "Capitaine Cursors";
        package = pkgs.capitaine-cursors;
        size = 8;
      };
      theme = {
        name = "Dracula";
        package = pkgs.dracula-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };

    home.file.".icons/default/cursors".source =
      "${pkgs.capitaine-cursors}/share/icons/capitaine-cursors/cursors";

    home.pointerCursor = {
      name = "Capitaine Cursors";
      package = pkgs.capitaine-cursors;
      size = 8;
      x11.enable = true;
      gtk.enable = true;
    };

    home.packages = with pkgs; [
      # apps
      bitwarden
      bottles
      darktable
      davinci-resolve
      ffmpeg
      ffmpeg-normalize
      firebird-emu
      gimp
      gtypist
      # hhkb-gnu
      inkscape
      libreoffice-fresh
      lieer
      masterpdfeditor
      notmuch
      obs-studio
      octaveFull
      qmk
      rbw
      rclone
      scrcpy
      speedtest-cli
      spotify-unwrapped
      via
      xournalpp
      youtube-dl
      zathura
      zoom-us

      # games
      bsdgames
      lutris

      # social
      discord
      element-desktop
      signal-desktop
      wechat-uos

      # devtools
      fd
      fzf
      insomnia
      picocom
      ripgrep
      silver-searcher
      valgrind
      # ide
      arduino
      ghidra
      # kicad
      quartus-prime-lite
      # bash
      shfmt
      # c / c++
      avrdude
      catch2
      clang_14
      clang-tools_14
      cmakeFix.cmakeWithGui
      gdb
      gnumake
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
      texlab
      texlive.combined.scheme-full
      # markdown
      marksman
      # mips
      mars-mips
      qtspim
      # nix
      direnv
      nixpkgs-fmt
      # nodejs
      nodejs
      nodejs-16_x
      # pascal
      fpc
      # python
      black
      pythonWithMyPackages
      nodePackages.pyright
      # rust
      cargo
      rustc
      rust-analyzer
      # verilog
      svls
      # yaml
      nodePackages.yaml-language-server
    ];

    programs = {
      chromium = {
        enable = false;
        package = pkgs.google-chrome-dev;
      };
      firefox = {
        enable = true;
        package = pkgs.latest.firefox-nightly-bin;
        profiles = let
          defaultSettings = {
            "extensions.pocket.enabled" = false;
            "general.smoothScroll.msdPhysics.enabled" = true;
            "network.dns.echconfig.enabled" = true;
            "network.dns.use_https_rr_as_altsvc" = true;
            "network.security.esni.enabled" = true;
            "security.enterprise_roots.enabled" = true;
          };
        in {
          default = {
            id = 0;
            path = "0.default";
            settings = defaultSettings;
          };
          captive-browser = {
            id = 1;
            path = "1.captive-browser";
            settings = defaultSettings;
          };
        };
      };
      emacs = {
        enable = true;
        package = emacsPinnedPkgs.emacsPgtkNativeComp;
        extraPackages = (epkgs: [ epkgs.vterm ]);
      };
      vscode = {
        enable = true;
        package = pkgs.vscode;
        extensions = with pkgs.vscode-extensions; [
          ms-vscode.cpptools
          ms-vscode-remote.remote-ssh
          ms-vsliveshare.vsliveshare
        ];
      };
    };

    xdg = {
      configFile = {
        "nixpkgs/config.nix".text = ''
          { allowUnfree = true; }
        '';
        "captive-browser.toml".source =
          ./dotfiles/captive-browser/captive-browser.toml;
        "kitty/kitty.conf".source = ./dotfiles/kitty/kitty.conf;
        "mpv/input.conf".source = ./dotfiles/mpv/input.conf;
        "mpv/mpv.conf".source = ./dotfiles/mpv/mpv.conf;
        "ranger/rc.conf".source = ./dotfiles/ranger/rc.conf;
      };
      desktopEntries = {
        code = {
          name = "Visual Studio Code";
          genericName = "Text Editor";
          comment = "Code Editing. Redefined.";
          icon = "code";
          exec =
            "code --ignore-gpu-blacklist --enable-gpu-rasterization --enable-native-gpu-memory-buffers %F";
          startupNotify = true;
          settings = {
            Keywords = "vscode";
            StartupWMClass = "Code";
          };
          categories = [ "Utility" "TextEditor" "Development" "IDE" ];
          mimeType = [ "text/plain" "inode/directory" ];
          actions = {
            "new-empty-window" = {
              exec =
                "code --new-window --ignore-gpu-blacklist --enable-gpu-rasterization --enable-native-gpu-memory-buffers %F";
              icon = "code";
              name = "New Empty Window";
            };
          };
        };
        davinci-resolve = {
          name = "DaVinci Resolve";
          genericName = "DaVinci Resolve";
          comment =
            "Revolutionary new tools for editing, visual effects, color correction and professional audio post production, all in a single application!";
          icon = "davinci-resolve";
          exec = "davinci-resolve";
          mimeType = [ "application/x-resolveproj" ];
        };
        discord = {
          name = "Discord";
          genericName =
            "All-in-one cross-platform voice and text chat for gamers";
          icon = "discord";
          exec =
            "Discord --enable-accelerated-mjpeg-decode --enable-accelerated-video --ignore-gpu-blacklist --enable-native-gpu-memory-buffers --enable-gpu-rasterization";
          categories = [ "Network" "InstantMessaging" ];
          mimeType = [ "x-scheme-handler/discord" ];
        };
      };
    };
  };
}
