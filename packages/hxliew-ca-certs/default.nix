{ runCommand, requireFile, buildcatrust }:

let
  name = "hxliew-ca-certs";
  version = "1.0";

in runCommand name rec {
  serverRootCA = requireFile rec {
    name = "server_rootCA.crt";
    url = "file:///home/haoxiangliew/haoxiangliew/hxSSH/server_rootCA.crt";
    sha256 = "19iy1nqj1qb0r5zrijalay3j5j2hbjscahl37j1nrwdqa5f4xpfd";
  };
  nextdnsCA = requireFile rec {
    name = "NextDNS.cer";
    url = "file:///home/haoxiangliew/haoxiangliew/hxSSH/NextDNS.cer";
    sha256 = "0zl3x0jbixy8dq110rx1v35ywkgv7klbf37y3a5w8szzh6mvcpya";
  };

  buildInputs = [ buildcatrust ];
} ''
  install_path=$out/etc/ssl/certs
  mkdir -p $install_path

  buildcatrust \
    --ca_bundle_input $serverRootCA $nextdnsCA \
    --ca_bundle_output hxliew-ca-bundle.crt

  install -D -t "$install_path" hxliew-ca-bundle.crt
''
