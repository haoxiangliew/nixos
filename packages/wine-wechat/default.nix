{ stdenv

  # Update WeChat
  # https://github.com/microsoft/winget-pkgs/tree/master/manifests/t/Tencent/WeChat
, version ? "3.7.6.29"
, sha256 ? "147C4C1270CC3D159116AAB3B35130ED62C48EFBFF2D2369B3874EF34CDF57BB"

, fetchurl
, pkgs
, lib
, p7zip
, wine
, winetricks
, writeShellScript
, ...
}:

let
  wineGecko = stdenv.mkDerivation rec {
    pname = "wine-gecko";
    version = "2.47.3";
    src = fetchurl {
      url = "http://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86.tar.xz";
      sha256 = "1csx2c1zkjdk1qcd54crh34dkc1rn354q16gfykshh34vpriilq8";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      tar xf ${src} -C $out
    '';
  };

  wechatWine = wine.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./wine-wechat.patch
    ];

    postInstall = (old.postInstall or "") + ''
      rm -rf $out/share/wine/gecko
      ln -sf ${wineGecko} $out/share/wine/gecko
    '';
  });

  # wechatWine = wine;

  wechatFiles = stdenv.mkDerivation rec {
    pname = "wechat";
    inherit version;

    src = fetchurl {
      url = "https://webcdn.m.qq.com/spcmgr/download/WeChatSetup_${version}.exe";
      inherit sha256;
    };

    nativeBuildInputs = [ p7zip ];

    unpackPhase = ''
      7z x ${src}
      rm -rf \$*
    '';

    installPhase = ''
      mkdir $out
      cp -r * $out/
    '';
  };

  startWechat = writeShellScript "wine-wechat" ''
    export WINEARCH="win32"
    export WINEPREFIX="$HOME/.local/share/wine-wechat"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"
    export PATH="${wechatWine}/bin:$PATH"
    export LANG="zh_CN.UTF-8"

    winetricks() {
      grep $1 $WINEPREFIX/winetricks.log >/dev/null || ${winetricks}/bin/winetricks $1
    }

    ${wechatWine}/bin/wineboot
    winetricks msls31
    winetricks riched20

    ${wechatWine}/bin/wine regedit.exe ${./fonts.reg}
    ${wechatWine}/bin/wine ${wechatFiles}/WeChat.exe
    ${wechatWine}/bin/wineserver -k
  '';

  startWinecfg = writeShellScript "wine-wechat-cfg" ''
    export WINEARCH="win32"
    export WINEPREFIX="$HOME/.local/share/wine-wechat"
    export WINEDLLOVERRIDES="winemenubuilder.exe=d"
    export PATH="${wechatWine}/bin:$PATH"
    export LANG="zh_CN.UTF-8"

    winetricks() {
      grep $1 $WINEPREFIX/winetricks.log >/dev/null || ${winetricks}/bin/winetricks $1
    }

    ${wechatWine}/bin/wineboot
    winetricks msls31
    winetricks riched20

    ${wechatWine}/bin/wine regedit.exe ${./fonts.reg}
    ${wechatWine}/bin/wine winecfg.exe
    ${wechatWine}/bin/wineserver -k
  '';
in
stdenv.mkDerivation {
  pname = "wine-wechat";
  inherit version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${startWechat} $out/bin/wine-wechat
    ln -s ${startWinecfg} $out/bin/wine-wechat-cfg
    ln -s ${./share} $out/share
  '';

  meta = with lib; {
    description = "Wine WeChat";
    homepage = "https://weixin.qq.com/";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}
