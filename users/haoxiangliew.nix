{ config, pkgs, lib, ... }:

{
  programs.fish.enable = true;

  environment = {
    variables = {
      EDITOR = "emacs";
      FZF_DEFAULT_COMMAND =
        "fd --type file --color=always --strip-cwd-prefix --hidden --exclude .git";
      FZF_DEFAULT_OPTS = "--ansi";
    };
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock-origin
      "dcpihecpambacapedldabdbpakmachpb;https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/src/updates/updates.xml" # bypass-paywalls
      "gfolbeacfbanmnohmnppjgenmmajffop;https://younesaassila.github.io/ttv-lol-pro/updates.xml" # ttv-lol-pro
    ];
  };

  users = {
    users.haoxiangliew = {
      createHome = true;
      home = "/home/haoxiangliew";
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [ "wheel" ];
    };
  };
}
