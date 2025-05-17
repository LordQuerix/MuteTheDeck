#!/bin/bash

# Export environment for PulseAudio to work as user deck
export XDG_RUNTIME_DIR=/run/user/1000

BACKUP_FILE="/tmp/deck_volume_backup.txt"

# Save current volume %
CURRENT_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
echo "$CURRENT_VOL" > "$BACKUP_FILE"

# Mute volume
pactl set-sink-volume @DEFAULT_SINK@ 0%