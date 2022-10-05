#!/usr/bin/env bash

status=$(xinput --list-props 'AT Translated Set 2 keyboard' | grep 'Device Enabled' | awk '{ print $4 }')

if [ $status == '1' ]; then
    polybar-msg hook keyboard-toggle 2
    xinput --disable 'AT Translated Set 2 keyboard' &&
        xmodmap -e "keycode 22 = BackSpace" &&
        xmodmap -e "keycode 51 = backslash bar" &&
        notify-send --hint=string:x-dunst-stack-tag:volume 'Laptop Keyboard disabled'
else
    polybar-msg hook keyboard-toggle 1
    xinput --enable 'AT Translated Set 2 keyboard' &&
        xmodmap -e "keycode 51 = BackSpace" &&
        xmodmap -e "keycode 22 = backslash bar" &&
        notify-send --hint=string:x-dunst-stack-tag:volume 'Laptop Keyboard enabled'
fi
