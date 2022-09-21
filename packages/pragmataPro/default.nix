{ runCommand, requireFile, unzip }:

let
  name = "pragmatapro-${version}";
  version = "0.829";
in

runCommand name
rec {
  src = requireFile rec {
    name = "PragmataPro${version}.zip";
    url = "file:///home/haoxiangliew/haoxiangliew/${name}";
    sha256 = "0x49rsbi7h4k4l7v7jk8v75yl65asj8p8m1d7p2m400fm7wbmz4k";
  };

  buildInputs = [ unzip ];
} ''
  unzip $src

  install_path=$out/share/fonts/truetype/pragmatapro
  mkdir -p $install_path

  find -name "PragmataPro*.ttf" -exec mv {} $install_path \;
''
