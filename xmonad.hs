import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Actions.SpawnOn
--import XMonad.Wallpaper
import Graphics.X11.ExtraTypes.XF86
import System.IO
import XMonad.Layout.Grid
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicBars
import XMonad.Util.Spotify

main = do
    --setRandomWallpaper ["$HOME/Pictures/nixos.png"]

    xmproc <- spawnPipe "xmobar"

    xmonad $ docks $ ewmh defaultConfig
        { manageHook = manageDocks <+> (isFullscreen --> doFullFloat) <+> (className =? "mpv" --> doFloat) <+> manageHook defaultConfig
        , startupHook = do
                spawn "picom -b --experimental-backends"
                spawnHere "feh --bg-scale ~/Pictures/nixos.png"
                -- spawnOn "workspace2" "pulseeffects"
                spawn "pulseeffects --gapplication-service"
                spawn "numlockx"
                spawn "emacs --daemon"
                spawn "ibus-daemon"
        , layoutHook = avoidStruts  $ layoutHook defaultConfig ||| Grid
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "#98c379" "" . shorten 100
                        , ppCurrent = xmobarColor "#61afef" "" . wrap "[" "]"
                        }
        , handleEventHook    = fullscreenEventHook
        , borderWidth        = 1
        , modMask            = mod4Mask
        , terminal           = "alacritty"
        , normalBorderColor  = "#2C323C"
        , focusedBorderColor = "#4B5363" }
        `additionalKeys`
        [
          ((mod4Mask, xK_p                   ), spawn "dmenu_run -fn 'monospace:regular:pixelsize=12' -nb '#282c34' -sf '#282c34' -sb '#98c379' -nf '#abb2bf'" ),
          ((mod4Mask, xK_c                   ), spawn "~/caffeine.sh"),
          ((mod4Mask, xK_Return              ), spawn "emacsclient -c"),
          ((mod4Mask, xK_b                   ), spawn "chromium --enable-features=WebUIDarkMode --force-dark-mode"),
          ((mod4Mask, xK_n                   ), spawn "chromium -incognito --enable-features=WebUIDarkMode --force-dark-mode"),
          ((mod4Mask, xK_l                   ), spawn "xautolock -locknow"),
          ((mod4Mask, xK_s                   ), spawn "maim -s -u | xclip -selection clipboard -t image/png -i"),
          ((mod4Mask .|. shiftMask, xK_s     ), spawn "maim -s"),
          ((mod4Mask, xK_f                   ), spawn "alacritty -e ranger"),
          ((mod4Mask, xK_m                   ), spawn "emacsclient -c -e '(=mu4e)'"),
          ((mod4Mask, xK_a                   ), spawn "emacsclient -c -e '(org-agenda)'"),
          ((mod4Mask, xK_Up                  ), audioPlayPause),
          ((mod4Mask, xK_Down                ), audioStop),
          ((mod4Mask, xK_Left                ), audioPrev),
          ((mod4Mask, xK_Right               ), audioNext),
          ((0       , xF86XK_Calculator       ), spawn "alacritty -e python3"),
          ((0       , xF86XK_AudioMute        ), spawn "amixer set Master toggle"),
          ((0       , xF86XK_AudioLowerVolume ), spawn "amixer -q set Master 2%-"),
          ((0       , xF86XK_AudioRaiseVolume ), spawn "amixer -q sset Master 2%+"),
          ((0       , xF86XK_MonBrightnessDown  ), spawn "xbacklight -dec 5"),
          ((0       , xF86XK_MonBrightnessUp  ), spawn "xbacklight -inc 5")
         ]
