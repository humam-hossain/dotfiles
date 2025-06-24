set -xe

echo "[INSTALL] waybar"
sudo pacman -S --noconfirm waybar

echo "[CONFIG] waybar"
mkdir -p ~/.config/waybar
cp -rf configs/waybar/* ~/.config/waybar/