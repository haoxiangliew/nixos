{ lib, stdenv, fetchurl, p7zip, gtk-engine-murrine }:

let
  themeName = "Catppuccin-Mocha-Standard-Mauve-Dark";
  version = "0.5.0";
  src = fetchurl {
    url =
      "https://github.com/catppuccin/gtk/releases/download/v${version}/Catppuccin-Mocha-Standard-Mauve-Dark.zip";
    sha256 = "03g9538w57b7q6mjxa3k5ibywvrslx86y4pxg5lfnmqy796kkc67";
  };

in stdenv.mkDerivation {
  pname = "catppuccin-gtk";
  inherit version;

  inherit src;

  nativeBuildInputs = [ p7zip ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  unpackPhase = ''
    7z x $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes/${themeName}
    cd ${themeName}
    cp -a {cinnamon,gnome-shell,gtk-2.0,gtk-3.0,gtk-4.0,index.theme,metacity-1,plank,xfwm4} $out/share/themes/${themeName}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for GTK";
    homepage = "https://github.com/catppuccin/gtk";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ haoxiangliew ];
  };
}
