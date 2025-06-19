<p align="center">
  <img src="MuteTheDeck.png" alt="MuteTheDeckBanner" width="600" />
</p>

# 🎧 MuteTheDeck 🔇

**MuteTheDeck** is a simple and useful **systemd service** for Steam Deck that automatically mutes the volume when the device suspends and restores it on resume — respecting your defined quiet hours ⏰.

---

## ❓ Why i made this

I made this script just so I can power on my Steam Deck at night without worrying that the game I’m playing at full volume will wake everyone up at home XD

---

## ❓ What it does & features
 
- 🔕 Automatically mutes volume on suspend  
- 🔊 Restores previous volume on resume, but only outside quiet hours  
- ⏳ Allows you to define your own quiet hours (e.g., night time)  
- ⚙️ Easy installer with uninstall support  

---

## 🤔 How does it work?  
When the Steam Deck is suspended, the service saves the current volume and sets it to zero. Upon resume, if outside the quiet hours, it restores the saved volume.

---

## ✅ Installation  

1. Download the latest release file from [here](https://github.com/LordQuerix/MuteTheDeck/releases/latest/download/MuteTheDeck.desktop)  
2. Place the downloaded file on your Desktop  
3. Open downloaded file

---

## ❌ Uninstallation  

Run the installer again and select Uninstall

---

## 📋 TODO

- [x] Mute volume on suspend  
- [x] Restore volume on resume, except during user-defined quiet hours  
- [x] Updater
- [x] Ability to change quiet hours without reinstalling  
- [x] Code optimization and cleanup


