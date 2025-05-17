#!/bin/bash

echo "=== Unmute script run at $(date) ==="

CONFIG_FILE="/opt/MuteTheDeck/config.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

HOUR=$(date +"%H")
echo "Current hour: $HOUR"

# Check quiet hours logic
if (( QUIET_START < QUIET_END )); then
  if (( HOUR >= QUIET_START && HOUR < QUIET_END )); then
    echo "Within quiet hours ($QUIET_START-$QUIET_END). Not restoring volume."
    exit 0
  fi
else
  if (( HOUR >= QUIET_START || HOUR < QUIET_END )); then
    echo "Within quiet hours ($QUIET_START-$QUIET_END). Not restoring volume."
    exit 0
  fi
fi

if [[ -f /tmp/deck_volume_backup.txt ]]; then
  SAVED_VOL=$(cat /tmp/deck_volume_backup.txt)
  echo "Restoring volume to $SAVED_VOL"
  if pactl set-sink-volume @DEFAULT_SINK@ "$SAVED_VOL"; then
    echo "Volume restored successfully."
    rm /tmp/deck_volume_backup.txt
  else
    echo "Failed to restore volume."
  fi
else
  echo "No volume backup found."
fi