set -xe

echo "[INSTALL] unzip & tar"
sudo pacman -Sy --noconfirm --needed unzip tar

echo "[INSTALL] micro"
sudo pacman -Sy --noconfirm --needed micro

echo "[INSTALL] vlc"
sudo pacman -Sy --noconfirm --needed vlc

echo "[INSTALL] gparted"
sudo pacman -Sy --noconfirm --needed gparted

echo "[INSTALL] libre-office"
sudo pacman -Sy --noconfirm --needed libreoffice-fresh

echo "[INSTALL] btop"
sudo pacman -Sy --noconfirm --needed btop

echo "[INSTALL] fastfetch"
sudo pacman -Sy --noconfirm --needed fastfetch

echo "[INSTALL] curl"
sudo pacman -Sy --noconfirm --needed curl

echo "[INSTALL] wget"
sudo pacman -Sy --noconfirm --needed wget