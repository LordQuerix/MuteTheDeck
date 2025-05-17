#!/bin/bash

### === MuteTheDeck Installer / Uninstaller ===
### Author: LordQuerix
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