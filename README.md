# Hyprland Configuration Files by Titus

![Screenshot](https://github.com/RumiAxolotl/hyprland-config/raw/main/darkmode.png)
![Screenshot](https://github.com/RumiAxolotl/hyprland-config/raw/main/lightmode.png)

## Installation

Ensure base-devel is installed before proceeding

### Yay

**Important**: Execute the following commands as a regular user, NOT as root!

```
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### Required Packages

``` bash
yay -S hyprland polkit-gnome ffmpeg neovim viewnior rofi      \
pavucontrol thunar starship wl-clipboard wf-recorder swaybg   \
grimblast-git ffmpegthumbnailer tumbler playerctl             \
noise-suppression-for-voice thunar-archive-plugin kitty       \
waybar-hyprland wlogout swaylock-effects sddm-git pamixer     \
nwg-look-bin dunst ttf-firacode-nerd noto-fonts \
noto-fonts-emoji ttf-nerd-fonts-symbols-common otf-firamono-nerd \
brightnessctl hyprpicker-git\
catppuccin-gtk-theme-mocha catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-frappe catppuccin-gtk-theme-latte
```

## Important Notes

- It is recommended to use `archinstall` with Sway as the desktop environment for the base installation.
- `SDDM-GIT` is required to avoid shutdown bugs and delays.
- Configure SDDM for autologin (for security, use `swaylock` at the beginning of the script).
- Replace `xdg-desktop-portal-wlr` with **[xdg-desktop-portal-hyprland-git](https://wiki.hyprland.org/hyprland-wiki/pages/Useful-Utilities/Hyprland-desktop-portal/)**.

