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
      "https://github.com/nixos/nixpkgs/archive/10ecda252ce1b3b1d6403caeadbcc8f30d5ab796.tar.gz";
  }) {
    config = config.nixpkgs.config;
    overlays = [
      (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/emacs-overlay/archive/99f607199684071fef8e8a411d4e5d862cd5647a.tar.gz";
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
        sha256 = "173wc5q3wqbx5p2qf5yvhgbwpds1v9v266285hzjv39r7zkb531k";
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
      googleChromeOverlay = (self: super: {
        google-chrome-dev = super.google-chrome-dev.override {
          commandLineArgs =
            "--use-gl=egl --enable-native-gpu-memory-buffers --force-dark-mode --enable-accelerated-video-decode --enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder --disable-features=UseChromeOSDirectVideoDecoder";
        };
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
      messengerOverlay = (self: super: {
        messenger = super.makeDesktopItem {
          name = "Messenger";
          desktopName = "Messenger";
          exec = ''
            ${google-chrome-dev}/bin/google-chrome-unstable --app="https://facebook.com/messages"'';
          terminal = false;
          type = "Application";
          icon = "messengerfordesktop";
          comment = "Facebook Messenger";
        };
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
            ${google-chrome-dev}/bin/google-chrome-unstable --app="https://usevia.app"'';
          terminal = false;
          type = "Application";
          icon = "via";
          comment = "Yet another keyboard configurator";
          categories = [ "Development" ];
        };
      });
      xournalppNightlyOverlay = (self: super: {
        xournalpp = super.xournalpp.overrideAttrs (oldAttrs: {
          src = builtins.fetchTarball
            "https://github.com/xournalpp/xournalpp/archive/refs/tags/nightly.tar.gz";
          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.alsa-lib ];
        });
      });
      packagesOverlay = (final: prev: {
        marksman = prev.callPackage ./packages/marksman { };
        wechat-uos = prev.callPackage ./packages/wechat-uos { };
        wine-wechat = prev.callPackage ./packages/wine-wechat { };
        quartus-prime-lite = prev.callPackage ./packages/quartus-prime { };
        hhkb-gnu = prev.callPackage ./packages/happy-hacking-gnu { };
      });
    in [
      discordOverlay
      draculaThemeOverlay
      googleChromeOverlay
      lieerOverlay
      lutrisOverlay
      masterPdfOverlay
      messengerOverlay
      nightlyOverlay
      pythonOverlay
      spicetifyOverlay
      viaAppOverlay
      xournalppNightlyOverlay
      packagesOverlay
    ];
  };

  environment.variables.EDITOR = "emacs -Q -nw -l ~/.emacs.d/editor-init.el";

  programs.chromium = {
    enable = true;
    extensions = [
      "dcpihecpambacapedldabdbpakmachpb;https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml"
      "ilcacnomdmddpohoakmgcboiehclpkmj;https://raw.githubusercontent.com/FastForwardTeam/releases/main/update/update.xml"
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
        name = "Dracula-cursors";
        package = pkgs.dracula-theme;
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
      # gtk2 = {
      #   extraConfig = ''
      #     gtk-key-theme-name = "Emacs"
      #   '';
      # };
      # gtk3 = { extraConfig = { gtk-key-theme-name = "Emacs"; }; };
    };

    home.file.".icons/default/cursors".source =
      "${pkgs.dracula-theme}/share/icons/Dracula-cursors/cursors";

    home.pointerCursor = {
      name = "Dracula-cursors";
      package = pkgs.dracula-theme;
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
      messenger
      signal-desktop
      wechat-uos

      # devtools
      criu
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
        enable = true;
        package = pkgs.google-chrome-dev;
      };
      firefox = {
        enable = false;
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
        emcs = {
          name = "Emacs (Simple)";
          genericName = "Text Editor";
          comment = "Edit text in a barebones environment";
          icon = "Emacs";
          exec = "emacs -Q -l /home/haoxiangliew/.emacs.d/editor-init.el";
          startupNotify = true;
          settings = { StartupWMClass = "Emacs"; };
          categories = [ "Utility" "Development" "TextEditor" ];
          mimeType = [
            "text/english"
            "text/plain"
            "text/x-makefile"
            "text/x-c++hdr"
            "text/x-c++src"
            "text/x-chdr"
            "text/x-csrc"
            "text/x-java"
            "text/x-moc"
            "text/x-pascal"
            "text/x-tcl"
            "text/x-tex"
            "application/x-shellscript"
            "text/x-c"
            "text/x-c++"
          ];
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
            "Discord --no-sandbox --ignore-gpu-blocklist --disable-features=UseOzonePlatform --enable-features=VaapiVideoDecoder --use-gl=desktop --enable-gpu-rasterization --enable-zero-copy";
          categories = [ "Network" "InstantMessaging" ];
          mimeType = [ "x-scheme-handler/discord" ];
        };
      };
    };
  };
}
