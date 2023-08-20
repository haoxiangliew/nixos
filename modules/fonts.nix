{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [ "JetBrainsMono" "NerdFontsSymbolsOnly" ];
      })
      cantarell-fonts
      cm_unicode
      corefonts
      font-awesome_4
      joypixels
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      vistafonts
      vistafonts-chs
      vistafonts-cht
    ];
    fontconfig = {
      enable = true;
      cache32Bit = true;
      defaultFonts = {
        serif = [
          "Liberation Serif"
          "Noto Serif"
          "Noto Serif SC"
          "Noto Serif TC"
        ];
        emoji = [ "JoyPixels" "Noto Emoji" "Noto Color Emoji" ];
        sansSerif =
          [ "Cantarell" "Noto Sans" "Noto Sans SC" "Noto Sans TC" ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
        ];
      };
    };
  };
}
