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
      name = "SF Pro";
      package = pkgs.apple-fonts;
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
      bitwarden
      croc
      ffmpeg
      qmk
      rbw
      rclone
      speedtest-cli
      yt-dlp
      zathura

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
      # c / c++
      clang
      clang-tools
      # cmake-language-server
      # cmakeWithGui
      # gdb
      # gnumake
      # libllvm
      # ninja
      # css
      nodePackages.vscode-css-languageserver-bin
      # git
      gitAndTools.delta
      # go
      go
      gopls
      # html
      nodePackages.vscode-html-languageserver-bin
      # markdown
      marksman
      # nix
      direnv
      hydra-check
      nix-prefetch
      nix-tree
      # nodejs
      nodejs
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
    ];
  };

  programs = {
    chromium = {
      enable = false;
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
      package = pkgs.emacs29-pgtk;
      extraPackages = (epkgs: [ epkgs.vterm ]);
    };
    vscode = {
      enable = false;
      package = pkgs.vscode.fhsWithPackages (ps: with ps; [ ]);
    };
  };
}
