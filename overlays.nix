{ config, pkgs, specialArgs, lib, inputs, ... }:

{
  nixpkgs.overlays = let
    armcordVersion = "3.2.1";
    armcordOverlay = (self: super: {
      armcord = super.armcord.overrideAttrs (oldAttrs: {
        version = "${armcordVersion}";
        src = builtins.fetchurl {
          url =
            "https://github.com/ArmCord/ArmCord/releases/download/v${armcordVersion}/ArmCord_${armcordVersion}_amd64.deb";
          sha256 = "1cfbypn9kh566s09c1bvxswpc0r11pmsvxlh4dixd5s622ia3h7r";
        };
      });
    });
    lutrisOverlay = (self: super: {
      lutris = super.lutris.overrideAttrs (oldAttrs: {
        extraPkgs = (oldAttrs.extraPkgs or [ ]) ++ [ pkgs.xorg.libXtst ];
        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or [ ])
          ++ [ pkgs.python3Packages.pypresence ];
      });
    });
    masterPdfVersion = "5.9.50";
    masterPdfOverlay = (self: super: {
      masterpdfeditor = super.masterpdfeditor.overrideAttrs (oldAttrs: {
        src = builtins.fetchurl {
          url =
            "https://code-industry.net/public/master-pdf-editor-${masterPdfVersion}-qt5.x86_64.tar.gz";
          sha256 = "1q3wq39f2yl019riwfz1i9kziydf18lis94gl44nmflm06gj9ik2";
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
      spotify-unwrapped = super.callPackage ./packages/spicetify/spicetify.nix {
        inherit (super) spotify-unwrapped;
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
    packagesOverlay = (final: prev: {
      apple-fonts = prev.callPackage ./packages/apple-fonts { };
      # pragmataPro = prev.callPackage ./packages/pragmataPro { };
      # catppuccin-gtk-mocha = prev.callPackage ./packages/catppuccin-gtk { };
      # quartus-prime-lite = prev.callPackage ./packages/quartus-prime { };
      spotify = prev.callPackage ./packages/spotify { };
      my-ca-certs = prev.callPackage ./packages/hxliew-ca-certs { };
    });
  in [
    armcordOverlay
    inputs.emacsunstable.overlay
    inputs.fenix.overlays.default
    inputs.mozilla.overlays.firefox
    lutrisOverlay
    masterPdfOverlay
    packagesOverlay
    pythonOverlay
  ];
}
