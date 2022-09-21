{ spotify-unwrapped, lib, fetchFromGitHub, formats, spicetify-cli }:
let
  booleanToString = boolean: if boolean then "1" else "0";
  listToString = list: lib.concatStringsSep "|" list;

  # nix-shell -p nix-prefetch --run 'nix-prefetch fetchFromGitHub --owner spicetify --repo spicetify-themes --rev master'
  dribbblish = "${
      fetchFromGitHub {
        owner = "spicetify";
        repo = "spicetify-themes";
        rev = "master";
        sha256 = "sha256-OI0CiZE9GKaXVa5I8kCXlrfjX8izynKi5sJxPQK0Zd8=";
      }
  }/Dribbblish";

  configFile = (formats.ini { }).generate "config-xpui.ini"
    {
      Setting = {
        current_theme = "Dribbblish";
        color_scheme = "dracula";
        overwrite_assets = booleanToString true;
        check_spicetify_upgrade = booleanToString false;
        prefs_path = "PREFS_PATH";
        spotify_path = "SPOTIFY_PATH";
        inject_css = booleanToString true;
        replace_colors = booleanToString true;
        spotify_launch_flags = listToString [ ];
      };

      Preprocesses = {
        disable_ui_logging = booleanToString true;
        remove_rtl_rule = booleanToString true;
        expose_apis = booleanToString true;
        disable_upgrade_check = booleanToString true;
        disable_sentry = booleanToString true;
      };

      AdditionalOptions = {
        extensions = listToString [ "dribbblish.js" ];
        custom_apps = listToString [ ];
        sidebar_config = booleanToString true;
        home_config = booleanToString true;
        experimental_features = booleanToString true;
      };

      Patch = {
        "xpui.js_find_8008" = ",(\w+=)32,";
        "xpui.js_repl_8008" = ",\${1}56,";
      };

      Backup = {
        version = "";
        "with" = "";
      };
    };
in
spotify-unwrapped.overrideAttrs (oldAttrs: {
  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ spicetify-cli ];

  # ln -s ${dribbblish}/dribbblish.js $spicetifyDir/Extensions/dribbblish.js
  # ln -s ${dribbblish} $spicetifyDir/Themes/Dribbblish

  postInstall = (oldAttrs.postInstall or "") + ''
    export HOME=$TMP

    spicetifyDir=$(dirname "$(spicetify-cli -c)")

    cp -r ${dribbblish}/dribbblish.js $spicetifyDir/Extensions/dribbblish.js
    cp -r ${dribbblish} $spicetifyDir/Themes/Dribbblish

    touch $out/prefs
    cp -f ${configFile} $spicetifyDir/config-xpui.ini

    substituteInPlace $spicetifyDir/Themes/Dribbblish/color.ini \
      --replace "44475a" "282a36" \
      --replace "6272a4" "1e2029" \
      --replace "ffb86c" "bd93f9"

    substituteInPlace $spicetifyDir/config-xpui.ini \
      --replace "PREFS_PATH" "$out/prefs" \
      --replace "SPOTIFY_PATH" "$out/share/spotify"

    spicetify-cli backup apply
  '';
})
