#!/usr/bin/env bash

status=`xset -q | grep 'DPMS is' | awk '{ print $3 }'`

if [ $status == 'Enabled' ]; then
    polybar-msg hook caffeine 2
    xset -dpms && xset s off && xautolock -disable && \
    notify-send --hint=string:x-dunst-stack-tag:volume 'Caffeine is on'
else
    polybar-msg hook caffeine 1
    xset +dpms && xset s on && xautolock -enable && \
    notify-send --hint=string:x-dunst-stack-tag:volume 'Caffeine is off'
fi
