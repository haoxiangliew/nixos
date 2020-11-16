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

main = do
    --setRandomWallpaper ["$HOME/Pictures/nixos.png"]

    xmproc <- spawnPipe "xmobar"

    xmonad $ docks defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig
        , startupHook = do
                spawnHere "xloadimage -onroot -fullscreen ~/Pictures/nixos.png"
                -- spawnOn "workspace2" "pulseeffects"
        , layoutHook = avoidStruts  $ layoutHook defaultConfig ||| Grid
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "#98c379" "" . shorten 100
                        , ppCurrent = xmobarColor "#61afef" "" . wrap "[" "]"
                        }
        , borderWidth        = 1
        , modMask            = mod4Mask
        , terminal           = "alacritty"
        , normalBorderColor  = "#2C323C"
        , focusedBorderColor = "#4B5363" }
        `additionalKeys`
        [
          ((mod4Mask, xK_p                   ), spawn "dmenu_run -fn 'monospace:regular:pixelsize=12' -nb '#282c34' -sf '#282c34' -sb '#98c379' -nf '#abb2bf'" ) ,
          ((0       , xF86XK_AudioMute        ), spawn "amixer set Master toggle"),
          ((0       , xF86XK_AudioLowerVolume ), spawn "amixer -q set Master 2%-"),
          ((0       , xF86XK_AudioRaiseVolume ), spawn "amixer -q sset Master 2%+"),
          ((0       , xF86XK_MonBrightnessDown  ), spawn "xbacklight -dec 5"),
          ((0       , xF86XK_MonBrightnessUp  ), spawn "xbacklight -inc 5")
         ]
