set -xe

echo "[INSTALL] wpa_supplicant networkmanager"
sudo pacman -Syu --noconfirm --needed wpa_supplicant networkmanager

echo "[CONFIG] enable NetworkManager.service"
sudo systemctl enable --now NetworkManager.service

echo "[STATUS] check NetworkManager status"
systemctl status NetworkManager.service

echo "[CONFIG] connect to wifi"
nmtui

echo "[STATUS] check network connection"
ping -c3 archlinux.org
