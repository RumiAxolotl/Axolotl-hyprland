# Hyprland Configuration Files by Rumi Axolotl

![Screenshot](https://github.com/RumiAxolotl/hyprland-config/raw/main/Screenshot2.png)
![Screenshot](https://github.com/RumiAxolotl/hyprland-config/raw/main/Screenshot1.png)

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
pavucontrol thunar starship wl-clipboard wf-recorder swww   \
grimblast ffmpegthumbnailer tumbler playerctl             \
noise-suppression-for-voice thunar-archive-plugin kitty       \
waybar wlogout wlsunset swaylock-effects sddm pamixer     \
nwg-look-bin dunst ttf-firacode-nerd noto-fonts \
noto-fonts-emoji ttf-nerd-fonts-symbols-common otf-firamono-nerd \
brightnessctl hyprpicker-git whitesur-gtk-theme\
catppuccin-gtk-theme-mocha catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-frappe catppuccin-gtk-theme-latte\

```


### Module Packages For Waybar

```bash
yay -S wttr btop 
```
