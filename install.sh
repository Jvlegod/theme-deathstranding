#!/usr/bin/env bash
set -e

THEME_NAME="deathstranding"
GRUB_THEME_DIR="/boot/grub/themes"
INSTALL_DIR="$GRUB_THEME_DIR/$THEME_NAME"

RES="1920x1080"

if [ $# -ge 1 ]; then
    RES="$1"
fi

echo "[INFO] Installing GRUB theme: $THEME_NAME ($RES)"

sudo mkdir -p "$INSTALL_DIR/about/assets"
sudo mkdir -p "$INSTALL_DIR/assets"

sudo cp -v unicode.pf2 "$INSTALL_DIR/"
sudo cp -v about/unifont.pf2 "$INSTALL_DIR/about/"

sed "s/\$\$RES\$\$/$RES/g" theme.txt | sudo tee "$INSTALL_DIR/theme.txt" > /dev/null
sed "s/\$\$RES\$\$/$RES/g" about/theme.txt | sudo tee "$INSTALL_DIR/about/theme.txt" > /dev/null

if [ -f "assets/deathstranding-$RES.png" ]; then
    sudo cp -v "assets/deathstranding-$RES.png" "$INSTALL_DIR/assets/deathstranding-$RES.png"
else
    echo "[WARN] Background for $RES not found, fallback to 1920x1080."
    sudo cp -v "assets/deathstranding-1920x1080.png" "$INSTALL_DIR/assets/deathstranding-$RES.png"
fi

if [ -f "about/assets/about-$RES.png" ]; then
    sudo cp -v "about/assets/about-$RES.png" "$INSTALL_DIR/about/assets/about-$RES.png"
else
    echo "[WARN] About background for $RES not found, fallback to 1920x1080."
    sudo cp -v "about/assets/about-1920x1080.png" "$INSTALL_DIR/about/assets/about-$RES.png"
fi

GRUB_CFG="/etc/default/grub"
if grep -q "GRUB_THEME=" "$GRUB_CFG"; then
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$INSTALL_DIR/theme.txt\"|" "$GRUB_CFG"
else
    echo "GRUB_THEME=\"$INSTALL_DIR/theme.txt\"" | sudo tee -a "$GRUB_CFG"
fi

echo "[INFO] Updating GRUB..."
if command -v update-grub >/dev/null 2>&1; then
    sudo update-grub
elif command -v grub-mkconfig >/dev/null 2>&1; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "[ERROR] Cannot find grub update command!"
    exit 1
fi

echo "[OK] Theme installed successfully for resolution $RES!"

