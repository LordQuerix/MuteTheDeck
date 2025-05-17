#!/bin/bash

CONFIG_FILE="/opt/MuteTheDeck/config.conf"
source "$CONFIG_FILE"

HOUR=$(date +"%H")

if (( QUIET_START == QUIET_END )); then
  # One full hour range
  echo "Quiet hour active (single hour match)"
  pactl set-sink-volume @DEFAULT_SINK@ 0%
  exit 0
fi

if (( QUIET_START < QUIET_END )); then
  if (( HOUR >= QUIET_START && HOUR < QUIET_END )); then
    echo "Within quiet hours"
    pactl set-sink-volume @DEFAULT_SINK@ 0%
    exit 0
  fi
else
  if (( HOUR >= QUIET_START || HOUR < QUIET_END )); then
    echo "Within quiet hours (overnight)"
    pactl set-sink-volume @DEFAULT_SINK@ 0%
    exit 0
  fi
fi

CURRENT_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1)
echo "$CURRENT_VOL" > /tmp/deck_volume_backup.txt
pactl set-sink-volume @DEFAULT_SINK@ 0%
