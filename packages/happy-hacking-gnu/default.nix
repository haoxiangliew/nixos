{ stdenv, lib, cmake, gcc, pkgconfig, systemd }:

stdenv.mkDerivation rec {
  pname = "happy-hacking-gnu";
  version = "master";

  src = builtins.fetchTarball
    "https://gitlab.com/dom/happy-hacking-gnu/-/archive/master/happy-hacking-gnu-master.tar.gz";

  buildInputs = [ cmake gcc pkgconfig systemd ];

  configurePhase = ''
    cd bin
    cmake ..
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv bin/hhg $out/bin
  '';
}
