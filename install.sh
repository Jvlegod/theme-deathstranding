#!/usr/bin/env bash
set -e

THEME_NAME="deathstranding"
GRUB_THEME_DIR="/boot/grub/themes"
INSTALL_DIR="$GRUB_THEME_DIR/$THEME_NAME"
GRUBD_DIR="/etc/grub.d"
ABOUT_SCRIPT="$GRUBD_DIR/40_custom_${THEME_NAME}_about"
GRUB_CFG="/etc/default/grub"

usage() {
    echo "Usage:"
    echo "  $0 install [RESOLUTION]"
    echo "  $0 uninstall"
    exit 1
}

install_theme() {
    RES="${1:-1920x1080}"
    echo "[INFO] Installing theme $THEME_NAME ($RES)"

    sudo mkdir -p "$INSTALL_DIR/about/assets"
    sudo mkdir -p "$INSTALL_DIR/assets"

    sudo cp -v unicode.pf2 "$INSTALL_DIR/"
    sudo cp -v about/unifont.pf2 "$INSTALL_DIR/about/"

    sed "s/\$\$RES\$\$/$RES/g" theme.txt | sudo tee "$INSTALL_DIR/theme.txt" > /dev/null
    sed "s/\$\$RES\$\$/$RES/g" about/theme.txt | sudo tee "$INSTALL_DIR/about/theme.txt" > /dev/null

    if [ -f "assets/deathstranding-$RES.png" ]; then
        sudo cp -v "assets/deathstranding-$RES.png" "$INSTALL_DIR/assets/deathstranding-$RES.png"
    else
        sudo cp -v "assets/deathstranding-1920x1080.png" "$INSTALL_DIR/assets/deathstranding-$RES.png"
    fi

    if [ -f "about/assets/about-$RES.png" ]; then
        sudo cp -v "about/assets/about-$RES.png" "$INSTALL_DIR/about/assets/about-$RES.png"
    else
        sudo cp -v "about/assets/about-1920x1080.png" "$INSTALL_DIR/about/assets/about-$RES.png"
    fi

    sudo tee "$ABOUT_SCRIPT" > /dev/null <<EOF
#!/bin/sh
exec tail -n +3 \$0
submenu "About machine" {
    menuentry "GRUB theme" {
        set theme=$INSTALL_DIR/about/theme.txt
        export theme
        terminal_output gfxterm
    }
}
EOF
    sudo chmod +x "$ABOUT_SCRIPT"

    if grep -q "GRUB_THEME=" "$GRUB_CFG"; then
        sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$INSTALL_DIR/theme.txt\"|" "$GRUB_CFG"
    else
        echo "GRUB_THEME=\"$INSTALL_DIR/theme.txt\"" | sudo tee -a "$GRUB_CFG"
    fi

    if command -v update-grub >/dev/null 2>&1; then
        sudo update-grub
    elif command -v grub-mkconfig >/dev/null 2>&1; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi

    echo "[OK] Theme installed."
}

uninstall_theme() {
    echo "[INFO] Uninstalling theme $THEME_NAME"

    sudo rm -rf "$INSTALL_DIR"
    sudo rm -f "$ABOUT_SCRIPT"
    sudo sed -i '/^GRUB_THEME=/d' "$GRUB_CFG"

    if command -v update-grub >/dev/null 2>&1; then
        sudo update-grub
    elif command -v grub-mkconfig >/dev/null 2>&1; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi

    echo "[OK] Theme uninstalled and GRUB restored."
}

case "$1" in
    install)
        install_theme "$2"
        ;;
    uninstall)
        uninstall_theme
        ;;
    *)
        usage
        ;;
esac

