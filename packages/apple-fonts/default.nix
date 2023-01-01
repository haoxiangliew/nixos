{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "apple-fonts";
  version = "latest";

  # nix-prefetch fetchFromGitHub --owner haoxiangliew --repo apple-fonts --rev <rev>
  src = fetchFromGitHub {
    owner = "haoxiangliew";
    repo = "apple-fonts";
    rev = "4c1470e299439c5ee4ded2e02fa5b568cdaac63e";
    sha256 = "sha256-3ejXS4PdSdSVNC9S9nxYb9A6UofNRtkTET4x3VZqnFg=";
  };

  installPhase = ''
    truetype_path=$out/share/fonts/truetype/apple-fonts
    mkdir -p $truetype_path

    opentype_path=$out/share/fonts/opentype/apple-fonts
    mkdir -p $opentype_path

    find -name "*.ttf" -exec mv {} $truetype_path \;
    find -name "*.otf" -exec mv {} $opentype_path \;
  '';

  meta = with lib; {
    description = "Fonts from Apple platforms";
    homepage = "https://developer.apple.com/fonts/";
    license = licenses.unfree;
    platforms = platforms.all;
    maintainers = with maintainers; [ haoxiangliew ];
  };
}
