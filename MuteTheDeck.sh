#!/bin/bash

### === MuteTheDeck Installer ===
### By: LordQuerix

set -e

SERVICE_NAME=MuteTheDeck
INSTALL_DIR="/opt/$SERVICE_NAME"
CONFIG_FILE="$INSTALL_DIR/config.conf"
BACKUP_FILE="/tmp/deck_volume_backup.txt"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/LordQuerix/MuteTheDeck/main"

MUTE_URL="$GITHUB_RAW_BASE/mute.sh"
UNMUTE_URL="$GITHUB_RAW_BASE/unmute.sh"
MUTE_SERVICE_URL="$GITHUB_RAW_BASE/mute.service"
UNMUTE_SERVICE_URL="$GITHUB_RAW_BASE/unmute.service"

cat << "BANNER"
  __  __       _    _______ _          _____            _
 |  \/  |     | |  |__   __| |        |  __ \          | |
 | \  / |_   _| |_ ___| |  | |__   ___| |  | | ___  ___| | __
 | |\/| | | | | __/ _ \ |  | '_ \ / _ \ |  | |/ _ \/ __| |/ /
 | |  | | |_| | ||  __/ |  | | | |  __/ |__| |  __/ (__|   <
 |_|  |_|\__,_|\__\___|_|  |_| |_|\___|_____/ \___|\___|_|\_\


BANNER

# Handle existing install
if [ -d "$INSTALL_DIR" ]; then
  CHOICE=$(kdialog --title "MuteTheDeck" \
    --menu "MuteTheDeck is already installed. What do you want to do?" \
    1 "Reinstall / Update" \
    2 "Change quiet hours" \
    3 "Uninstall")

  case $CHOICE in
    1)
      echo "Updating files..."
      wget -q -O "$INSTALL_DIR/mute.sh" "$MUTE_URL"
      wget -q -O "$INSTALL_DIR/unmute.sh" "$UNMUTE_URL"
      wget -q -O "/etc/systemd/system/$SERVICE_NAME.service" "$MUTE_SERVICE_URL"
      wget -q -O "/etc/systemd/system/${SERVICE_NAME}-resume.service" "$UNMUTE_SERVICE_URL"
      chmod +x "$INSTALL_DIR/mute.sh" "$INSTALL_DIR/unmute.sh"
      sudo systemctl daemon-reload
      kdialog --msgbox "MuteTheDeck updated successfully!"
      exit 0
      ;;
    2)
      QUIET_START=$(kdialog --title "Start Hour" --inputbox "Enter quiet hours start (0-23):" "22")
      QUIET_END=$(kdialog --title "End Hour" --inputbox "Enter quiet hours end (0-23):" "8")
      cat << EOF > "$CONFIG_FILE"
QUIET_START=$QUIET_START
QUIET_END=$QUIET_END
EOF
      kdialog --msgbox "Quiet hours updated."
      exit 0
      ;;
    3)
      sudo systemctl disable $SERVICE_NAME.service || true
      sudo systemctl disable ${SERVICE_NAME}-resume.service || true
      sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
      sudo rm -f /etc/systemd/system/${SERVICE_NAME}-resume.service
      sudo systemctl daemon-reload
      sudo rm -rf "$INSTALL_DIR"
      sudo rm -f "$BACKUP_FILE"
      kdialog --msgbox "MuteTheDeck has been uninstalled."
      exit 0
      ;;
    *)
      kdialog --msgbox "No action taken."
      exit 0
      ;;
  esac
fi

# Fresh install path
QUIET_START=$(kdialog --title "Start Hour" --inputbox "Enter quiet hours start (0-23):" "22")
QUIET_END=$(kdialog --title "End Hour" --inputbox "Enter quiet hours end (0-23):" "8")

sudo mkdir -p "$INSTALL_DIR"
sudo chown "$USER" "$INSTALL_DIR"

cat << EOF > "$CONFIG_FILE"
QUIET_START=$QUIET_START
QUIET_END=$QUIET_END
EOF

wget -q -O "$INSTALL_DIR/mute.sh" "$MUTE_URL"
wget -q -O "$INSTALL_DIR/unmute.sh" "$UNMUTE_URL"
wget -q -O "/etc/systemd/system/$SERVICE_NAME.service" "$MUTE_SERVICE_URL"
wget -q -O "/etc/systemd/system/${SERVICE_NAME}-resume.service" "$UNMUTE_SERVICE_URL"
chmod +x "$INSTALL_DIR/mute.sh" "$INSTALL_DIR/unmute.sh"

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME.service
sudo systemctl enable ${SERVICE_NAME}-resume.service

kdialog --msgbox "MuteTheDeck installed successfully!\nQuiet hours: $QUIET_START:00 to $QUIET_END:00"
exit 0
