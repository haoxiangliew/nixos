{
  allowUnfree = true;

  packageOverrides = pkgs:
    with pkgs; {
      usrpkgs = pkgs.buildEnv {
        name = "user-packages";
        paths = [
          # devtools
          adoptopenjdk-hotspot-bin-15
          black
          cabal-install
          ccls
          clang-tools
          hlint
          haskell-language-server
          glslang
          ghcid
          nixfmt
          pipenv
          shellcheck

          # haskell
          haskellPackages.hoogle

          # npm
          nodePackages.bash-language-server
          nodePackages.js-beautify
          nodePackages.stylelint
          nodePackages.typescript-language-server

          # pip
          python3Packages.isort
          python3Packages.nose
          python3Packages.pyflakes
          python3Packages.pytest
          python3Packages.python-language-server

          # ide
          arduino
          ((emacsPackagesNgGen emacs).emacsWithPackages
            (epkgs: [ epkgs.vterm ]))

          isync
          jq
          mu
          texlab
          texlive.combined.scheme-medium
          pandoc

          #apps
          discord-canary
          openconnect
          plex-mpv-shim
          scrcpy
          spotify
          youtube-dl
          zoom-us
          zotero
        ];
        pathsToLink = [ "/share" "/bin" ];
      };
    };
}
