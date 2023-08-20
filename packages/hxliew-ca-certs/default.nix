{ runCommand, requireFile, buildcatrust }:

let
  name = "hxliew-ca-certs";
  version = "1.0";

in
runCommand name
rec {
  serverRootCA = /home/haoxiangliew/haoxiangliew/hxSSH/server_rootCA.crt;
  nextdnsCA = /home/haoxiangliew/haoxiangliew/hxSSH/NextDNS.cer;
  syncthingCA = /home/haoxiangliew/haoxiangliew/hxSSH/nixos-syncthing.crt;

  buildInputs = [ buildcatrust ];
} ''
  install_path=$out/etc/ssl/certs
  mkdir -p $install_path

  buildcatrust \
    --ca_bundle_input $serverRootCA $nextdnsCA $syncthingCA \
    --ca_bundle_output hxliew-ca-bundle.crt

  install -D -t "$install_path" hxliew-ca-bundle.crt
''
