#/usr/bin/env bash

# killall -q polybar

pkill "polybar"

while pgrep -x polybar >/dev/null; do sleep 1; done

if type "xrandr"; then
	for output in $(xrandr -q | grep " connected primary" | cut -d ' ' -f1); do
		MONITOR=$output polybar main &
	done
	for output in $(xrandr -q | grep -v " connected primary" | grep " connected" | cut -d ' ' -f1); do
		if [[ "$output" = "DisplayPort-2" ]]; then
			MONITOR=$output polybar vertical &
		else
			MONITOR=$output polybar secondary &
		fi
	done
else
	polybar --reload main &
	polybar --reload secondary &
	polybar --reload vertical &
fi
