#!/bin/bash
# Define variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

# Set the script to exit on error
set -e

printf "$(tput setaf 2) Welcome to the Arch Linux YAY Hyprland installer!\n $(tput sgr0)"

sleep 2

printf "$YELLOW PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!
This script will overwrite some of your configs and files!"

sleep 2

printf "\n
$YELLOW  Some commands requires you to enter your password inorder to execute
If you are worried about entering your password, you can cancel the script now with CTRL Q or CTRL C and review contents of this script. \n"

sleep 3
#### Check for yay ####
ISYAY=/usr/bin/yay

if [ -f "$ISYAY" ]; then
    printf "\n%s - yay was located, moving on.\n" "$GREEN"
else 
    printf "\n%s - yay was NOT located\n" "$YELLOW"
    read -n1 -rep "${CAT} Would you like to install yay (y,n)" INST
    if [[ $INST =~ ^[Yy]$ ]]; then
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm 2>&1 | tee -a $LOG
        cd ..
    else
        printf "%s - yay is required for this script, now exiting\n" "$RED"
        exit
    fi
# update system before proceed
    printf "${YELLOW} System Update to avoid issue\n" 
    yay -Syu --noconfirm 2>&1 | tee -a $LOG
fi

# Function to print error messages
print_error() {
    printf " %s%s\n" "$RED" "$1" "$NC" >&2
}

# Function to print success messages
print_success() {
    printf "%s%s%s\n" "$GREEN" "$1" "$NC"
}






### Install all of the above pacakges ####
read -n1 -rep 'Would you like to install the packages? (y,n)' INST
echo

if [[ $inst =~ ^[Nn]$ ]]; then
    printf "${YELLOW} No packages installed. Goodbye! \n"
            exit 1
        fi

if [[ $INST == "Y" || $INST == "y" ]]; then

git_pkgs="grimblast-git sddm-git waybar-git"
   hypr_pkgs="hyprland wl-clipboard wf-recorder rofi wlogout hyprpicker hypridle hyprlock brightnessctl dunst swww kitty"    
   font_pkgs="ttf-nerd-fonts-symbols-common otf-firamono-nerd inter-font otf-sora ttf-fantasque-nerd noto-fonts noto-fonts-emoji ttf-comfortaa"
   font_pkgs2="ttf-jetbrains-mono-nerd ttf-icomoon-feather ttf-iosevka-nerd adobe-source-code-pro-fonts ttf-firacode-nerd ttf-pacifico"
   app_pkgs="nwg-look-bin qt5ct btop jq gvfs ffmpegthumbs mousepad mpv  playerctl pamixer noise-suppression-for-voice xarchiver wttr"
   app_pkgs2="polkit-gnome ffmpeg neovim viewnior pavucontrol thunar ffmpegthumbnailer tumbler thunar-archive-plugin xdg-user-dirs"
   theme_pkgs="catppuccin-gtk-theme-mocha reversal-icon-theme-git catppuccin-cursors-mocha"



    if ! yay -S --noconfirm $git_pkgs $hypr_pkgs $font_pkgs $font_pkgs2 $app_pkgs $app_pkgs2 $theme_pkgs 2>&1 | tee -a $LOG; then
        print_error " Failed to install additional packages - please check the install.log \n"
        exit 1
    fi
    xdg-user-dirs-update
    echo
    print_success " All necessary packages installed successfully."
else
    echo
    print_error " Packages not installed - please check the install.log"
    sleep 1
fi


### Copy Config Files ###
read -n1 -rep 'Would you like to copy config files? (y,n)' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
    echo -e "Copying config files...\n"
    cp -R ./dotconf/dunst ~/.config/ 2>&1 | tee -a $LOG
    cp -R ./dotconf/hypr ~/.config/ 2>&1 | tee -a $LOG
    cp -R ./dotconf/kitty ~/.config/ 2>&1 | tee -a $LOG
    cp -R ./dotconf/neofetch ~/.config/ 2>&1 | tee -a $LOG
    cp -R ./dotconf/pipewire ~/.config/ 2>&1 | tee -a $LOG
    cp -R ./dotconf/rofi ~/.config/ 2>&1 | tee -a $LOG
    cp -R ./dotconf/waybar ~/.config/ 2>&1 | tee -a $LOG
    cp -R ./dotconf/wlogout ~/.config/ 2>&1 | tee -a $LOG

    mkdir -p ~/Pictures/wallpapers
    cp -R ./wallpapers ~/Pictures/wallpapers/
    mkdir -p ~/Pictures/Screenshots
    
    # Set some files as exacutable 
    chmod +x ~/.config/hypr/xdg-portal-hyprland
    chmod +x ~/.config/waybar/scripts/*
fi

### Enable SDDM Autologin ###
read -n1 -rep 'Would you like to enable SDDM autologin? (y,n)' WIFI
if [[ $WIFI == "Y" || $WIFI == "y" ]]; then
    LOC="/etc/sddm.conf"
    echo -e "The following has been added to $LOC.\n"
    echo -e "[Autologin]\nUser = $(whoami)\nSession=hyprland" | sudo tee -a $LOC
    echo -e "\n"
    echo -e "Enable SDDM service...\n"
    sudo systemctl enable sddm
    sleep 3
fi
# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n)" BLUETOOTH
if [[ $BLUETOOTH =~ ^[Yy]$ ]]; then
    printf " Installing Bluetooth Packages...\n"
 blue_pkgs="bluez bluez-utils blueman"
    if ! yay -S --noconfirm $blue_pkgs 2>&1 | tee -a $LOG; then
       	print_error "Failed to install bluetooth packages - please check the install.log"    
    printf " Activating Bluetooth Services...\n"
    sudo systemctl enable --now bluetooth.service
    sleep 2
    fi
else
    printf "${YELLOW} No bluetooth packages installed...\n"
	fi

### Script is done ###
printf "\n${GREEN} Installation Completed.\n"
echo -e "${GREEN} You can start Hyprland by typing Hyprland (note the capital H).\n"
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n)" HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
    if command -v Hyprland >/dev/null; then
        exec Hyprland
    else
         print_error " Hyprland not found. Please make sure Hyprland is installed by checking install.log.\n"
        exit 1
    fi
else
    exit
fi
