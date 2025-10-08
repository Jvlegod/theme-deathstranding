#!/usr/bin/env bash
set -e

THEME_NAME="deathstranding"
GRUB_THEME_DIR="/boot/grub/themes"
INSTALL_DIR="$GRUB_THEME_DIR/$THEME_NAME"
GRUBD_DIR="/etc/grub.d"
ABOUT_SCRIPT="$GRUBD_DIR/40_custom_${THEME_NAME}_about"
GRUB_CFG="/etc/default/grub"

usage(){ echo "Usage: $0 install [RES] | uninstall"; exit 1; }

update_grub(){
  if command -v update-grub >/dev/null 2>&1; then
    sudo update-grub
  elif command -v grub2-mkconfig >/dev/null 2>&1; then
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  elif command -v grub-mkconfig >/dev/null 2>&1; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi
}

install_theme(){
  RES="${1:-1920x1080}"
  sudo mkdir -p "$INSTALL_DIR/about/assets" "$INSTALL_DIR/assets"
  sudo cp -v unicode.pf2 "$INSTALL_DIR/" || true
  sudo cp -v about/unifont.pf2 "$INSTALL_DIR/about/" || true
  sed 's/\$\$RES\$\$/'"$RES"'/g' theme.txt | sudo tee "$INSTALL_DIR/theme.txt" >/dev/null
  sed 's/\$\$RES\$\$/'"$RES"'/g' about/theme.txt | sudo tee "$INSTALL_DIR/about/theme.txt" >/dev/null
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
  sudo tee "$ABOUT_SCRIPT" >/dev/null <<EOF
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
  if grep -q "^GRUB_THEME=" "$GRUB_CFG"; then
    sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$INSTALL_DIR/theme.txt\"|" "$GRUB_CFG"
  else
    echo "GRUB_THEME=\"$INSTALL_DIR/theme.txt\"" | sudo tee -a "$GRUB_CFG" >/dev/null
  fi
  sudo chown -R root:root "$INSTALL_DIR"
  sudo find "$INSTALL_DIR" -type d -exec chmod 755 {} \;
  sudo find "$INSTALL_DIR" -type f -exec chmod 644 {} \;
  update_grub
  echo "OK: installed $THEME_NAME at $RES"
}

uninstall_theme(){
  sudo rm -rf "$INSTALL_DIR"
  sudo rm -f "$ABOUT_SCRIPT"
  sudo sed -i '/^GRUB_THEME=/d' "$GRUB_CFG"
  update_grub
  echo "OK: uninstalled $THEME_NAME"
}

case "$1" in
  install) install_theme "$2" ;;
  uninstall) uninstall_theme ;;
  *) usage ;;
esac

