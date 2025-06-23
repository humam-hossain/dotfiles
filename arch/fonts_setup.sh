set -xe

echo "[INSTALL] font awesome"
sudo pacman -Sy --noconfirm --needed ttf-font-awesome

echo "[INSTALL] jetbrains mono nerd font"
sudo pacman -Sy --noconfirm --needed ttf-jetbrains-mono-nerd

echo "[INSTALL] noto fonts"
sudo pacman -Sy --noconfirm --needed noto-fonts

echo "[SYNC] rebuild font cache"
fc-cache -fv