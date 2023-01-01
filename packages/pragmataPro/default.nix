{ runCommand, requireFile, unzip }:

let
  name = "pragmatapro-${version}";
  version = "0.829";

in runCommand name rec {
  src = requireFile rec {
    name = "PragmataPro${version}.zip";
    url = "file:///home/haoxiangliew/haoxiangliew/PragmataPro${version}.zip";
    sha256 = "0x49rsbi7h4k4l7v7jk8v75yl65asj8p8m1d7p2m400fm7wbmz4k";
  };

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
