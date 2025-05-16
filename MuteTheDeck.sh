#!/bin/bash

### === MuteTheDeck Installer / Uninstaller ===
### Author: YourName
### Description: Installs systemd services that mute Steam Deck on suspend and restore volume on resume outside quiet hours

set -e

clear

cat << "BANNER"
  __  __       _    _______ _          _____            _
 |  \/  |     | |  |__   __| |        |  __ \          | |
 | \  / |_   _| |_ ___| |  | |__   ___| |  | | ___  ___| | __
 | |\/| | | | | __/ _ \ |  | '_ \ / _ \ |  | |/ _ \/ __| |/ /
 | |  | | |_| | ||  __/ |  | | | |  __/ |__| |  __/ (__|   <
 |_|  |_|\__,_|\__\___|_|  |_| |_|\___|_____/ \___|\___|_|\_\


BANNER

echo -e "\nMuteTheDeck Installer\n"
echo -e "This script installs systemd services that:\n"
echo -e "• Mute your Steam Deck on suspend\n• Restore volume on resume (unless during quiet hours)\n• Allow you to set quiet hours\n"

SERVICE_NAME=MuteTheDeck
INSTALL_DIR="/opt/$SERVICE_NAME"
CONFIG_FILE="$INSTALL_DIR/config.conf"
BACKUP_FILE="/tmp/deck_volume_backup.txt"

# Check existing install
if [ -d "$INSTALL_DIR" ]; then
  echo -e "🔍 Detected existing installation at $INSTALL_DIR."
  read -p "Do you want to uninstall it? (y/N): " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "🔧 Uninstalling $SERVICE_NAME..."

    sudo systemctl disable $SERVICE_NAME.service || true
    sudo systemctl disable ${SERVICE_NAME}-resume.service || true
    sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
    sudo rm -f /etc/systemd/system/${SERVICE_NAME}-resume.service
    sudo systemctl daemon-reload
    sudo rm -rf "$INSTALL_DIR"
    sudo rm -f "$BACKUP_FILE"

    echo -e "\n🗑️ Uninstalled $SERVICE_NAME and removed all associated files."
    exit 0
  else
    echo -e "❌ Installation aborted."
    exit 1
  fi
fi

# Ask quiet hours
read -p "Enter start of quiet hours (0-23, default 22): " QUIET_START
QUIET_START=${QUIET_START:-22}
read -p "Enter end of quiet hours (0-23, default 8): " QUIET_END
QUIET_END=${QUIET_END:-8}

# Create install dir and set ownership
sudo mkdir -p "$INSTALL_DIR"
sudo chown "$USER":"$USER" "$INSTALL_DIR"

# Save config
cat << EOF > "$CONFIG_FILE"
QUIET_START=$QUIET_START
QUIET_END=$QUIET_END
EOF

# Create mute.sh
cat << 'EOF' > "$INSTALL_DIR/mute.sh"
#!/bin/bash

# Export environment for PulseAudio to work as user deck
export XDG_RUNTIME_DIR=/run/user/1000

BACKUP_FILE="/tmp/deck_volume_backup.txt"

# Save current volume %
CURRENT_VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
echo "$CURRENT_VOL" > "$BACKUP_FILE"

# Mute volume
pactl set-sink-volume @DEFAULT_SINK@ 0%
EOF

# Create unmute.sh
cat << 'EOF' > "$INSTALL_DIR/unmute.sh"
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
EOF

# Make scripts executable
chmod +x "$INSTALL_DIR/mute.sh"
chmod +x "$INSTALL_DIR/unmute.sh"

# Create systemd service files
sudo bash -c "cat > /etc/systemd/system/$SERVICE_NAME.service" << EOF
[Unit]
Description=Mute volume on suspend
Before=sleep.target

[Service]
Type=oneshot
User=deck
Environment=XDG_RUNTIME_DIR=/run/user/1000
ExecStart=$INSTALL_DIR/mute.sh

[Install]
WantedBy=sleep.target
EOF

sudo bash -c "cat > /etc/systemd/system/${SERVICE_NAME}-resume.service" << EOF
[Unit]
Description=Restore volume on resume (if not during quiet hours)
After=suspend.target

[Service]
Type=oneshot
User=deck
Environment=XDG_RUNTIME_DIR=/run/user/1000
ExecStart=$INSTALL_DIR/unmute.sh

[Install]
WantedBy=suspend.target
EOF

# Enable and reload
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl enable ${SERVICE_NAME}-resume.service

echo -e "\n✅ Installed successfully! Your Steam Deck will mute on suspend and restore volume on resume (except during quiet hours $QUIET_START:00-$QUIET_END:00)."
echo -e "To uninstall, run this script again and confirm removal."
