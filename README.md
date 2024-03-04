# <span style="color: #b4befe;"> Hyprland Configuration Files by Rumi Axolotl </span>

![Screenshot](https://github.com/RumiAxolotl/hyprland-config/raw/main/Screenshot1.png)
![Screenshot](https://github.com/RumiAxolotl/hyprland-config/raw/main/Screenshot2.png)

## <span style="color: #89dceb;">Installation</span>

Ensure `base-devel` is installed before proceeding.

### <span style="color: #94e2d5;">Yay</span>

**Important**: Execute the following commands as a regular user, NOT as root!

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### <span style="color: #a6e3a1;">Required Packages</span>

```bash
yay -S hyprland polkit-gnome ffmpeg neovim viewnior rofi      \
pavucontrol thunar starship wl-clipboard wf-recorder swww   \
grimblast ffmpegthumbnailer tumbler playerctl             \
noise-suppression-for-voice thunar-archive-plugin kitty       \
waybar wlogout wlsunset sddm pamixer     \
nwg-look-bin dunst ttf-firacode-nerd noto-fonts \
noto-fonts-emoji ttf-nerd-fonts-symbols-common otf-firamono-nerd \
brightnessctl hyprpicker hypridle hyprlock whitesur-gtk-theme\
catppuccin-gtk-theme-mocha catppuccin-gtk-theme-macchiato catppuccin-gtk-theme-frappe catppuccin-gtk-theme-latte\

```

### <span style="color: #f9e2af;">Module Packages For Waybar </span>

```bash
yay -S wttr btop
```
