#!/usr/bin/env bash

status=$(xinput --list-props 'AT Translated Set 2 keyboard' | grep 'Device Enabled' | awk '{ print $4 }')

if [ $status == '1' ]; then
    polybar-msg hook keyboard-toggle 2
    xinput --disable 'AT Translated Set 2 keyboard' &&
        notify-send --hint=string:x-dunst-stack-tag:volume 'Laptop Keyboard disabled' && echo 'Laptop Keyboard disabled'
else
    polybar-msg hook keyboard-toggle 1
    xinput --enable 'AT Translated Set 2 keyboard' &&
        notify-send --hint=string:x-dunst-stack-tag:volume 'Laptop Keyboard enabled' && echo 'Laptop Keyboard enabled'
fi
