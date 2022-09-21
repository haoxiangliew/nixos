#!/usr/bin/env bash

wacompen=$(xsetwacom --list | grep -i "pen" |  awk '{print $(NF-2)}')
wacompad=$(xsetwacom --list | grep -i "pad" |  awk '{print $(NF-2)}')

if type "xrandr"; then
    for output in $(xrandr -q | grep " connected primary" | cut -d ' ' -f1); do
	# wacom ctl-4100wl
	xsetwacom set $wacompen MapToOutput $output
	xsetwacom set $wacompad MapToOutput $output

	xsetwacom set $wacompad Button 1 "key shift ctrl p"
	xsetwacom set $wacompad Button 2 "key shift ctrl e"
	xsetwacom set $wacompad Button 3 "key ctrl s"
	xsetwacom set $wacompad Button 8 "key ctrl e"

	# huion h950p
        # xinput map-to-output 'HID 256c:006d Pen stylus' $output
	# xinput map-to-output 'HID 256c:006d Pad pad' $output
    done
fi

