set -xe

echo "[INSTALL] kitty"
sudo pacman -Sy --noconfirm --needed kitty

echo "[CONFIG] kitty"
mkdir -p ~/.config/kitty
cp -f ./config/kitty/kitty.conf ~/.config/kitty/kitty.conf