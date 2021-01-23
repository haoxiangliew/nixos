#!/usr/bin/env bash
status=`xset -q | grep 'DPMS is' | awk '{ print $3 }'`
if [ $status == 'Enabled' ]; then
  xset -dpms && xset s off && xautolock -disable && \
  notify-send 'Screen suspend is disabled.'
else
  xset +dpms && xset s on && xautolock -enable && \
  notify-send 'Screen suspend is enabled.'
fi
