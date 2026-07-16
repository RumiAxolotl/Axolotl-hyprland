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

    git_pkgs="grimblast-git noctalia-git"
    hypr_pkgs="hyprland hyprpicker"
    font_pkgs="inter-font maplemono-nf-cn-unhinted maplemono-nf-unhinted maplemono-ttf noto-fonts noto-fonts-emoji polkit-gnome ttf-nerd-fonts-symbols-common"
    # Core desktop — needed first to get into and use the system
    app_pkgs="dunst fcitx5-im fcitx5-unikey kitty rofi rofi-emoji sddm wl-clipboard wlogout"
    # System utilities — hardware control, audio, monitoring, recording
    app_pkgs2="brightnessctl btop jq noise-suppression-for-voice pamixer playerctl wf-recorder wttr"
    # Appearance — theming and Qt/GTK configurators
    app_pkgs3="font-manager lxappearance-qt nwg-look qt5ct qt6ct"
    # File management & media — file manager, thumbnails, media apps, editor
    app_pkgs4="ffmpeg ffmpegthumbnailer ffmpegthumbs gvfs mpv neovim pavucontrol rar thunar thunar-archive-plugin tumbler unzip viewnior xarchiver xdg-user-dirs zip"
    # Daily use apps
    app_pkgs5="discord spotify visual-studio-code-bin zen-browser-bin"


    if ! yay -S --noconfirm $git_pkgs $hypr_pkgs $font_pkgs $app_pkgs $app_pkgs2 $app_pkgs3 $app_pkgs4 $app_pkgs5 2>&1 | tee -a $LOG; then
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
    # Copy all files from dotfiles directory to ~/.config/
    cp -R ./dotfiles/* ~/.config/ 2>&1 | tee -a $LOG

    read -n1 -rep 'Would you like to set up fonts from the repository/submodule? (y,n)' FONTS
    echo
    if [[ $FONTS == "Y" || $FONTS == "y" ]]; then
        echo -e "Preparing fonts...\n"
        if [ -d "./fonts" ]; then
            if [ -z "$(find ./fonts -mindepth 1 -maxdepth 1 2>/dev/null)" ]; then
                echo "Fonts directory is empty. Initializing submodule..."
                git submodule update --init --recursive 2>&1 | tee -a $LOG
            fi
            echo "Fonts will be managed from the repository/submodule. No files were copied."
        else
            echo "No fonts directory found. Fonts will be handled separately."
        fi
    else
        echo "Skipping font setup."
    fi

    cp -R ./wallpapers ~/Pictures/
    mkdir -p ~/Pictures/Screenshots
    
    # Set some files as exacutable 
    chmod +x ~/.config/hypr/xdg-portal-hyprland
    chmod +x ~/.config/hypr/scripts/*
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

### Install ZSH ###
read -n1 -rep "${CAT} Would you like to install ZSH and set it as your default shell? (y,n)" ZSH
if [[ $ZSH =~ ^[Yy]$ ]]; then
    printf " Installing ZSH...\n"
    if ! yay -S --noconfirm zsh zsh-completions 2>&1 | tee -a $LOG; then
        print_error " Failed to install ZSH - please check the install.log\n"
    else
        print_success " ZSH installed successfully."
        chsh -s $(which zsh)
        printf "${YELLOW} ZSH set as default shell. Please log out and back in for changes to take effect.\n"
    fi

    # Install Oh My Zsh
    printf " Installing Oh My Zsh...\n"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended 2>&1 | tee -a $LOG
    print_success " Oh My Zsh installed."

    # Install plugins
    printf " Installing ZSH plugins...\n"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>&1 | tee -a $LOG
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>&1 | tee -a $LOG
    print_success " ZSH plugins installed."

    # Install Powerlevel10k theme
    printf " Installing Powerlevel10k theme...\n"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 2>&1 | tee -a $LOG
    print_success " Powerlevel10k installed."

    # Edit ~/.zshrc — set theme and add plugins
    printf " Backing up ~/.zshrc...\n"
    cp ~/.zshrc ~/.zshrc.bak
    print_success " ~/.zshrc backed up to ~/.zshrc.bak"
    printf " Configuring ~/.zshrc...\n"
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc
    print_success " ~/.zshrc configured."
else
    printf "${YELLOW} ZSH not installed.\n"
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
