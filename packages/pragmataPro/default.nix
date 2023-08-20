{ runCommand, requireFile, unzip }:

let
  name = "pragmatapro-${version}";
  version = "0.829";

in
runCommand name
rec {
  src = /home/haoxiangliew/haoxiangliew/PragmataPro0.829.zip;

  buildInputs = [ unzip ];
} ''
  unzip $src

  truetype_path=$out/share/fonts/truetype/pragmatapro
  mkdir -p $truetype_path

  opentype_path=$out/share/fonts/opentype/pragmatapro
  mkdir -p $opentype_path

  find -name "PragmataPro*.ttf" -exec mv {} $truetype_path \;
  find -name "PragmataPro*.otf" -exec mv {} $opentype_path \;
''
