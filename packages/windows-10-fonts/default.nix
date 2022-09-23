{ runCommand, requireFile, unzip }:

let
  name = "windows-10-fonts-${version}";
  version = "21H2";

in runCommand name rec {
  src = requireFile rec {
    name = "Win10_${version}_English_x64_fonts.zip";
    url =
      "file:///home/haoxiangliew/haoxiangliew/Win10_${version}_English_x64_fonts.zip";
    sha256 = "0m2skjh8yyq3px9dkypyfj9qbijb7h46pdvpjgn339cy72w2g72d";
  };

  buildInputs = [ unzip ];
} ''
  unzip $src

  install_path=$out/share/fonts/
  install_path_truetype=$out/share/fonts/truetype/
  mkdir -p $install_path_truetype

  find -name "*.ttf" -exec mv {} $install_path_truetype \;
  find -name "*.ttc" -exec mv {} $install_path \;
''
