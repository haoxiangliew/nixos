{ stdenv, lib, makeWrapper, fetchurl, autoPatchelfHook, zlib, writeShellScript
, version ? "2022-09-13" }:

let
  marksman-bin = stdenv.mkDerivation rec {
    pname = "marksman-bin";
    inherit version;

    src = fetchurl {
      url =
        "https://github.com/artempyanykh/marksman/releases/download/${version}/marksman-linux";
      sha256 = "1hr96dlix80ajc9jbg4nfq42k1i8xa7m9gnlxcn88w5zm4svvlys";
    };

    nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

    buildInputs = [ stdenv.cc.cc.lib zlib ];

    dontUnpack = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      # install -Dm755 ${src} $out/bin/marksman
      install -Dm755 ${src} $out/marksman
    '';
  };

  startMarksman = writeShellScript "marksman" ''
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
    ${marksman-bin}/marksman
  '';

in stdenv.mkDerivation rec {
  pname = "marksman";
  inherit version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${startMarksman} $out/bin/marksman
  '';

  meta = with lib; {
    description =
      "Markdown LSP server providing completion, cross-references, diagnostics, and more";
    homepage = "https://github.com/artempyanykh/marksman";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ haoxiangliew ];
  };
}
