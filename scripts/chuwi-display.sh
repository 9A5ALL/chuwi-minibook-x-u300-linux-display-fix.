#!/bin/bash
# Keep the display landscape after Cinnamon login/resume.
# Intended for a single-user X11 desktop where DISPLAY=:0.
export DISPLAY=:0
while true; do
    STATE=$(xrandr --query 2>/dev/null | grep '^DSI-1 connected')
    if [[ -n "$STATE" && ! "$STATE" =~ ^DSI-1[[:space:]]connected.*[[:space:]]right[[:space:]]\( ]]; then
        xrandr --output DSI-1 --rotate right
    fi
    sleep 5
done
