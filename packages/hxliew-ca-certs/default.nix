{ runCommand, requireFile, buildcatrust }:

let
  name = "hxliew-ca-certs";
  version = "1.0";

in runCommand name rec {
  serverRootCA = requireFile rec {
    name = "server_rootCA.crt";
    url = "file:///home/haoxiangliew/haoxiangliew/hxSSH/server_rootCA.crt";
    sha256 = "1dxvdi9mzxy9c693gwlc99zyr13v62q8c86zsnjhlsz1hjfmyw7f";
  };
  nextdnsCA = requireFile rec {
    name = "NextDNS.cer";
    url = "file:///home/haoxiangliew/haoxiangliew/hxSSH/NextDNS.cer";
    sha256 = "0zl3x0jbixy8dq110rx1v35ywkgv7klbf37y3a5w8szzh6mvcpya";
  };
  relayCA = requireFile rec {
    name = "relay.pem";
    url = "file:///home/haoxiangliew/haoxiangliew/hxSSH/relay.pem";
    sha256 = "1mva7b6c6a9bn3k0q3zgpv58gxdc4yza14axz13j1kx7b55h6rm1";
  };

  buildInputs = [ buildcatrust ];
} ''
  install_path=$out/etc/ssl/certs
  mkdir -p $install_path

  buildcatrust \
    --ca_bundle_input $serverRootCA $nextdnsCA $relayCA \
    --ca_bundle_output hxliew-ca-bundle.crt

  install -D -t "$install_path" hxliew-ca-bundle.crt
''
