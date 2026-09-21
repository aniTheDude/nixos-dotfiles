#!/usr/bin/env bash

TARGET="DP-1"
MODE="preferred"
POS="0x0"
SCALE="1"

if hyprctl monitors -j | jq -e --arg name "$TARGET" '.[] | select(.name == $name)' >/dev/null; then
  # Disable monitor
  hyprctl eval "hl.set_option('monitor', '$TARGET,disable')"
else
  # Re-enable on the far left
  hyprctl eval "hl.set_option('monitor', '$TARGET,$MODE,$POS,$SCALE')"
fi
