set -xe

echo "[CONFIG] Hyprland autolaunch"
MARKER="# <<< Hyprland auto-launch block >>>"
BLOCK=$(cat <<'EOF'
if [[ -z $WAYLAND_DISPLAY && $(tty) = /dev/tty1 ]]; then
    exec Hyprland
fi
EOF
)

if grep -Fxq "${MARKER}" ~/.bash_profile; then
    echo "Hyprland block already installed in ${PROFILE}."
    exit 0
fi

{
    echo
    echo "$MARKER"
    echo "$BLOCK"
    echo 
} >> ~/.bash_profile

echo "[VERIFY] hyprland autolaunch"
cat ~/.bash_profile
