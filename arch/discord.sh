set -xe

echo "[INSTALL] discord from yay"
yay -Sy --noconfirm --needed discord

echo "[CHECK] version"
yay -Si discord
