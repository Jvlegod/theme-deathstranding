# Usage

## 更改/etc/default/grub

增加选项

```bash
...
GRUB_THEME="/boot/grub/themes/deathstranding/theme.txt"
GRUB_GFXMODE=1920x1080 # 改成你的分辨率
...
```

## 默认主题安装(1920x1080)

```bash
./install.sh install
```

## 其他分辨率安装

```bash
./install.sh install 1366x768
```

## 卸载主题

```bash
./install.sh uninstall
```
