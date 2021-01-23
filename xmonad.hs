import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import XMonad.Actions.SpawnOn
import Graphics.X11.ExtraTypes.XF86
import System.IO

import XMonad.Layout.Grid
import XMonad.Layout.Spacing
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicBars
import XMonad.Util.Spotify
import XMonad.Actions.GridSelect

import Data.Maybe(maybeToList)
import Control.Monad(join, when)
import XMonad.Hooks.SetWMName

addNETSupported :: Atom -> X ()
addNETSupported x   = withDisplay $ \dpy -> do
    r               <- asks theRoot
    a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
    a               <- getAtom "ATOM"
    liftIO $ do
       sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
       when (fromIntegral x `notElem` sup) $
         changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen   = do
    wms <- getAtom "_NET_WM_STATE"
    wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
    mapM_ addNETSupported [wms, wfs]

main = do

    xmproc <- spawnPipe "xmobar"

    xmonad $ docks $ ewmh defaultConfig
        { manageHook = manageDocks <+> (isFullscreen --> doFullFloat) <+> (className =? "mpv" --> doFloat) <+> manageHook defaultConfig
        , startupHook = do
                spawnHere "feh --bg-fill ~/haoxiangliew/Wallpapers/hayasaka-nsfw.jpg"
                spawn "pulseeffects --gapplication-service"
                spawn "numlockx"
                spawn "emacs --daemon"
                spawn "ibus-daemon"
                spawn "plex-mpv-shim"
                spawn "picom -b"
                setWMName "LG3D"
                addEWMHFullscreen
        , layoutHook = avoidStruts $ spacing 5 $ GridRatio (16/10) ||| Mirror (GridRatio (1/defaultRatio)) ||| layoutHook defaultConfig
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "#98c379" "" . shorten 70
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
          ((mod4Mask .|. shiftMask, xK_p       ), spawn "dmenu_run -i -fn 'monospace:regular:pixelsize=12' -nb '#282c34' -sf '#282c34' -sb '#98c379' -nf '#abb2bf'" ),
          ((mod4Mask, xK_p                     ), spawn "j4-dmenu-desktop --dmenu=\"dmenu -i -fn 'monospace:regular:pixelsize=12' -nb '#282c34' -sf '#282c34' -sb '#98c379' -nf '#abb2bf'\""),
          ((mod4Mask, xK_c                     ), spawn "~/caffeine.sh"),
          ((mod4Mask .|. shiftMask, xK_t       ), spawn "alacritty"),
          ((mod4Mask, xK_Return                ), spawn "emacsclient -c -e '(+eshell/here)'"),
          ((mod4Mask .|. shiftMask, xK_Return  ), spawn "emacsclient -c -e '(+vterm/here default-directory)'"),
          ((mod4Mask, xK_b                     ), spawn "firefox"),
          ((mod4Mask, xK_n                     ), spawn "firefox -private-window"),
          ((mod4Mask .|. shiftMask, xK_b       ), spawn "google-chrome-stable"),
          ((mod4Mask .|. shiftMask, xK_n       ), spawn "google-chrome-stable -incognito"),
          ((mod4Mask, xK_g                     ), goToSelected defaultGSConfig),
          ((mod4Mask, xK_l                     ), spawn "xautolock -locknow"),
          ((mod4Mask, xK_s                     ), spawn "maim -s -u | xclip -selection clipboard -t image/png -i"),
          ((mod4Mask .|. shiftMask, xK_s       ), spawn "maim -s ~/Pictures/$(date +%s).png"),
          ((mod4Mask .|. shiftMask, xK_f       ), spawn "alacritty -e ranger"),
          ((mod4Mask .|. shiftMask, xK_d       ), spawn "autorandr --change"),
          ((mod4Mask, xK_f                     ), spawn "emacsclient -c -e '(dired default-directory)'"),
          ((mod4Mask, xK_d                     ), spawn "emacsclient -c"),
          ((mod4Mask, xK_m                     ), spawn "emacsclient -c -e '(=mu4e)'"),
          ((mod4Mask, xK_a                     ), spawn "emacsclient -c -e '(org-agenda)'"),
          ((mod4Mask, xK_Up                    ), audioPlayPause),
          ((mod4Mask, xK_Down                  ), audioStop),
          ((mod4Mask, xK_Left                  ), audioPrev),
          ((mod4Mask, xK_Right                 ), audioNext),
          ((0       , xF86XK_Calculator        ), spawn "alacritty -e python3"),
          ((0       , xF86XK_AudioMute         ), spawn "amixer set Master toggle"),
          ((0       , xF86XK_AudioLowerVolume  ), spawn "amixer -q set Master 2%- && notify-send -t 500 \"Volume: $(pactl list sinks | grep -i volume | head -1 | awk '{print $5}' | sed -e 's/%//')%\""),
          ((0       , xF86XK_AudioRaiseVolume  ), spawn "amixer -q sset Master 2%+ && notify-send -t 500 \"Volume: $(pactl list sinks | grep -i volume | head -1 | awk '{print $5}' | sed -e 's/%//')%\""),
          ((0       , xF86XK_MonBrightnessDown ), spawn "xbacklight -dec 5 && notify-send -t 500 \"Brightness: $(printf '%.0f' $(xbacklight -get))%\""),
          ((0       , xF86XK_MonBrightnessUp   ), spawn "xbacklight -inc 5 && notify-send -t 500 \"Brightness: $(printf '%.0f' $(xbacklight -get))%\"")
         ]
