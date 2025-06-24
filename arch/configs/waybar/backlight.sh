#!/usr/bin/env bash

# external display ID (as ddcutil sees it)
EXT_ID="1"         # or "HDMI-1", adjust to your setup
STEP=5             # percent step
ICONS=(        )

# read current brightness of external via ddcutil
get_brightness() {
  # try to read via ddcutil; fallback to 0 if error
  val=$(ddcutil --display "$EXT_ID" getvcp 10 2>/dev/null \
    | awk -F'[=,]' '/current value/ {gsub(/ /, "", $2); print $2}')
  echo $(( val < 0 ? 0 : val > 100 ? 100 : val ))
}

# set brightness (clamped to [0..100])
set_brightness() {
  target=$1
  (( target < 0 )) && target=0
  (( target > 100 )) && target=100
  ddcutil --display "$EXT_ID" setvcp 10 "$target" \
    >/dev/null 2>&1
}

# main dispatch
case "$1" in
  up)
    cur=$(get_brightness)
    set_brightness $(( cur + STEP ));;
  down)
    cur=$(get_brightness)
    set_brightness $(( cur - STEP ));;
  toggle)
    cur=$(get_brightness)
    # toggle between 10% and 100%
    if (( cur < 50 )); then set_brightness 100
    else set_brightness 10; fi;;
esac

# output JSON for Waybar
cur=$(get_brightness)
# pick icon slot: scale 0–100 into 0–(len-1)
idx=$(( cur * (${#ICONS[@]}-1) / 100 ))
icon=${ICONS[idx]}
echo "{\"icon\":\"$icon\",\"value\":$cur}"
