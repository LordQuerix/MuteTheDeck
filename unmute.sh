#!/bin/bash

CONFIG_FILE="/opt/MuteTheDeck/config.conf"
source "$CONFIG_FILE"

HOUR=$(date +"%H")

if (( QUIET_START == QUIET_END )); then
  echo "Quiet hour still active (single hour match)"
  exit 0
fi

if (( QUIET_START < QUIET_END )); then
  if (( HOUR >= QUIET_START && HOUR < QUIET_END )); then
    echo "Still within quiet hours"
    exit 0
  fi
else
  if (( HOUR >= QUIET_START || HOUR < QUIET_END )); then
    echo "Still within quiet hours (overnight)"
    exit 0
  fi
fi

if [[ -f /tmp/deck_volume_backup.txt ]]; then
  SAVED_VOL=$(cat /tmp/deck_volume_backup.txt)
  echo "Restoring volume to $SAVED_VOL"
  pactl set-sink-volume @DEFAULT_SINK@ "$SAVED_VOL"
  rm /tmp/deck_volume_backup.txt
else
  echo "No backup file found"
fi
