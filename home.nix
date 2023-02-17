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
  emacsPinnedPkgs = import (builtins.fetchTarball {
    url =
      "https://github.com/nixos/nixpkgs/archive/28319deb5ab05458d9cd5c7d99e1a24ec2e8fc4b.tar.gz";
  }) {
    config = config.nixpkgs.config;
    overlays = [
      (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/emacs-overlay/archive/cd34501a9bcec341533c7131af77572456c100d8.tar.gz";
      }))
    ];
  };

in {
  imports = [
    (import "${home-manager}/nixos")
    ./environments/gnome-home.nix
    ./vscode.nix
  ];

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
      armcordVersion = "3.1.4";
      armcordOverlay = (self: super: {
        armcord = super.armcord.overrideAttrs (oldAttrs: {
          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.pipewire ];
          version = "${armcordVersion}";
          src = builtins.fetchurl
            "https://github.com/ArmCord/ArmCord/releases/download/v${armcordVersion}/ArmCord_${armcordVersion}_amd64.deb";
          sha256 = "12gk4b2mmfq36argz9j43j3h5x5p010zk2vi09kih2ipdrqw7z07";
        });
      });
      openasar = builtins.fetchurl {
        url =
          "https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar";
        sha256 = "0cygr2xihdr5qz24v0gbrax08vr9h8w8cm190v6fkbggjb8x8417";
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
          vendorSha256 = "sha256-zYIbtcDM9iYSRHagvI9D284Y7w0ZxG4Ba1p4jqmQyng=";
          postInstall = (old.postInstall or "") + ''
            cp -r ${spicetify-src}/css-map.json $out/bin/css-map.json
          '';
        });
        spotify-unwrapped =
          super.callPackage ./packages/spicetify/spicetify.nix {
            inherit (super) spotify-unwrapped;
          };
      });
      ventoyVersion = "1.0.88";
      ventoyOverlay = (self: super: {
        ventoy-bin = super.ventoy-bin.overrideAttrs (old: {
          version = "${ventoyVersion}";
          src = builtins.fetchurl {
            url =
              "https://github.com/ventoy/Ventoy/releases/download/v${ventoyVersion}/ventoy-${ventoyVersion}-linux.tar.gz";
            sha256 = "0c0w6isvrffz2kl1ppfcc54487q5msmi20na5syi68j4fk6ms3cs";
          };
        });
      });
      viaAppOverlay = (self: super: {
        via = super.makeDesktopItem {
          name = "VIA";
          desktopName = "VIA";
          exec =
            ''${chromium}/bin/chromium -incognito --app="https://usevia.app"'';
          terminal = false;
          type = "Application";
          icon = "via";
          comment = "Yet another keyboard configurator";
          categories = [ "Development" ];
        };
      });
      vscodeInsidersOverlay = (self: super: {
        vscode-insiders =
          (super.vscode.override { isInsiders = true; }).overrideAttrs
          (oldAttrs: rec {
            name = "vscode-insiders";
            version = "latest";
            src = builtins.fetchTarball
              "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
          });
      });
      xournalppOverlay = (self: super: {
        xournalpp = super.xournalpp.overrideAttrs (oldAttrs: {
          src = builtins.fetchTarball
            "https://github.com/xournalpp/xournalpp/archive/refs/tags/v1.1.3.tar.gz";
          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.alsa-lib ];
        });
      });
      packagesOverlay = (final: prev: {
        armcord = prev.callPackage ./packages/armcord { };
        marksman = prev.callPackage ./packages/marksman { };
        wechat-uos = prev.callPackage ./packages/wechat-uos { };
        wine-wechat = prev.callPackage ./packages/wine-wechat { };
        quartus-prime-lite = prev.callPackage ./packages/quartus-prime { };
      });
    in [
      draculaThemeOverlay
      lieerOverlay
      lutrisOverlay
      masterPdfOverlay
      firefoxOverlay
      pythonOverlay
      rustOverlay
      ventoyOverlay
      viaAppOverlay
      vscodeInsidersOverlay
      packagesOverlay
    ];
  };

  environment = {
    variables = {
      EDITOR = "mg";
      FZF_DEFAULT_COMMAND = "fd --type file --follow --color=always";
      FZF_DEFAULT_OPTS = "--ansi";
    };
    shellAliases = {
      emcs = "emacs -Q -nw -l /home/haoxiangliew/.emacs.d/editor-init.el";
      emcsg = "emacs -Q -l /home/haoxiangliew/.emacs.d/editor-init.el";
    };
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock-origin
      "dcpihecpambacapedldabdbpakmachpb;https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml" # bypass-paywalls
      "ilcacnomdmddpohoakmgcboiehclpkmj;https://raw.githubusercontent.com/FastForwardTeam/releases/main/update/update.xml" # fastforward
    ];
  };

  vscode = {
    user = "haoxiangliew";
    homeDir = "/home/haoxiangliew";
    extensions = with pkgs.vscode-extensions;
      [ ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "cpptools";
          publisher = "ms-vscode";
          version = "latest";
          sha256 = "sha256-5JODuuOZBfdLSOkuAdSF4yI92EGfjWqNM9kBBeYwrJo=";
        }
        {
          name = "remote-ssh";
          publisher = "ms-vscode-remote";
          version = "latest";
          sha256 = "sha256-m6prKl3ecjPodXsa90f/LlFPB2cTarNQyGXT/hx6st4=";
        }
        {
          name = "vsliveshare";
          publisher = "ms-vsliveshare";
          version = "latest";
          sha256 = "sha256-QViwZBxem0z62BLhA0zbFdQL3SfoUKZQx6X+Am1lkT0=";
        }
      ];
  };

  home-manager.users.haoxiangliew = {

    home.stateVersion = config.system.nixos.release;

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
        name = "SF Pro";
        package = pkgs.apple-fonts;
        size = 11;
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
      armcord
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
      lieer
      masterpdfeditor
      notmuch
      obs-studio
      octaveFull
      plex-mpv-shim
      qmk
      rbw
      rclone
      scrcpy
      speedtest-cli
      # spotify-unwrapped
      spotify
      (ventoy-bin.override {
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
      picocom
      ripgrep
      silver-searcher
      vagrant
      valgrind
      # ide
      arduino
      ghidra
      # kicad
      mg
      quartus-prime-lite
      # c / c++
      avrdude
      catch2
      clang_15
      clang-tools_15
      cmake-language-server
      cmakeWithGui
      gdb
      gnumake
      lcov
      ninja
      pkgsCross.avr.buildPackages.binutils
      pkgsCross.avr.buildPackages.gcc
      qt6.full
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
      # lua
      luaPackages.lua-lsp
      stylua
      # markdown
      marksman
      # mips
      qtspim
      # nix
      direnv
      hydra-check
      nix-prefetch
      nix-tree
      # nodejs
      nodejs-16_x
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
        package = emacsPinnedPkgs.emacsPgtk;
        extraPackages = (epkgs: [ epkgs.vterm ]);
      };
      vscode = {
        enable = true;
        package = pkgs.vscode-insiders;
      };
    };

    xdg = {
      configFile = {
        "nixpkgs/config.nix".text = ''
          {
            allowUnfree = true;
            permittedInsecurePackages = [
              "python-2.7.18.6"
            ];
          }
        '';
        "mpv/input.conf".source = ./dotfiles/mpv/input.conf;
        "mpv/mpv.conf".source = ./dotfiles/mpv/mpv.conf;
        "plex-mpv-shim/input.conf".source = ./dotfiles/mpv/input.conf;
        "plex-mpv-shim/mpv.conf".source = ./dotfiles/mpv/mpv.conf;
        "ranger/rc.conf".source = ./dotfiles/ranger/rc.conf;
      };
      desktopEntries = {
        armcord = {
          name = "ArmCord";
          exec =
            "armcord --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer";
          terminal = false;
          icon = "armcord";
          comment =
            "ArmCord is a custom client designed to enhance your Discord experience while keeping everything lightweight.";
          categories = [ "Network" ];
        };
        # google-chrome = {
        #   name = "Google Chrome";
        #   genericName = "Web Browser";
        #   comment = "Access the Internet";
        #   exec =
        #     "google-chrome-stable --use-gl=egl --enable-native-gpu-memory-buffers --force-dark-mode --gtk-version=4 --enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks --disable-features=UseChromeOSDirectVideoDecoder";
        #   startupNotify = true;
        #   terminal = false;
        #   icon = "google-chrome";
        #   categories = [ "Network" "WebBrowser" ];
        #   mimeType = [
        #     "application/pdf"
        #     "application/rdf+xml"
        #     "application/rss+xml"
        #     "application/xhtml+xml"
        #     "application/xhtml_xml"
        #     "application/xml"
        #     "image/gif"
        #     "image/jpeg"
        #     "image/png"
        #     "image/webp"
        #     "text/html"
        #     "text/xml"
        #     "x-scheme-handler/http"
        #     "x-scheme-handler/https"
        #   ];
        #   actions = {
        #     new-window = {
        #       name = "New Window";
        #       exec =
        #         "google-chrome-stable --use-gl=egl --enable-native-gpu-memory-buffers --force-dark-mode --gtk-version=4 --enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks --disable-features=UseChromeOSDirectVideoDecoder";
        #     };
        #     new-incognito-window = {
        #       name = "New Incognito Window";
        #       exec =
        #         "google-chrome-stable --incognito --use-gl=egl --enable-native-gpu-memory-buffers --force-dark-mode --gtk-version=4 --enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks --disable-features=UseChromeOSDirectVideoDecoder";
        #     };
        #   };
        # };
        # google-chrome-unstable = {
        #   name = "Google Chrome (unstable)";
        #   genericName = "Web Browser";
        #   comment = "Access the Internet";
        #   exec =
        #     "google-chrome-unstable --use-gl=egl --enable-native-gpu-memory-buffers --force-dark-mode --gtk-version=4 --enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks --disable-features=UseChromeOSDirectVideoDecoder --ozone-platform-hint=x11";
        #   startupNotify = true;
        #   terminal = false;
        #   icon = "google-chrome-unstable";
        #   categories = [ "Network" "WebBrowser" ];
        #   mimeType = [
        #     "application/pdf"
        #     "application/rdf+xml"
        #     "application/rss+xml"
        #     "application/xhtml+xml"
        #     "application/xhtml_xml"
        #     "application/xml"
        #     "image/gif"
        #     "image/jpeg"
        #     "image/png"
        #     "image/webp"
        #     "text/html"
        #     "text/xml"
        #     "x-scheme-handler/http"
        #     "x-scheme-handler/https"
        #   ];
        #   actions = {
        #     new-window = {
        #       name = "New Window";
        #       exec =
        #         "google-chrome-unstable --use-gl=egl --enable-native-gpu-memory-buffers --force-dark-mode --gtk-version=4 --enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks --disable-features=UseChromeOSDirectVideoDecoder --ozone-platform-hint=x11";
        #     };
        #     new-incognito-window = {
        #       name = "New Incognito Window";
        #       exec =
        #         "google-chrome-unstable --incognito --use-gl=egl --enable-native-gpu-memory-buffers --force-dark-mode --gtk-version=4 --enable-features=WebUIDarkMode,VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks --disable-features=UseChromeOSDirectVideoDecoder --ozone-platform-hint=x11";
        #     };
        #   };
        # };
      };
    };
  };
}
