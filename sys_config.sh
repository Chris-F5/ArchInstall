#!/bin/bash

disk=$1
log_file=$2

printf "" > $log_file

# REQUIRED PACKAGES
xorg_packages="xorg-server xorg-xinit libx11 libxinerama libxft webkit2gtk"
required_packages="git networkmanager grub $xorg_packages"

echo ">>> Installing required packages '$required_packages':" >> $log_file
pacman --noconfirm -Sy $required_packages 2>&1 | tee -a $log_file

# NETWORK MANAGER

echo ">>> Enabling network manager: " >> $log_file
systemctl enable NetworkManager 2>&1 | tee -a $log_file

# BOOTLOADER

echo "Installing grub:"
echo ">>> Installing grub:" >> $log_file
grub-install $disk 2>&1 | tee -a $log_file
grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | tee -a $log_file

# LOCALE

locale="en_GB.UTF-8"
echo ">>> Setting locale to '$locale':" >> $log_file
sed -i "/^#$locale/s/^#//" /etc/locale.gen
locale-gen 2>&1 | tee -a $log_file
echo "LANG=$locale" > /etc/locale.conf

xorg_keymap="gb"

zone="Europe/London"
echo ">>> Setting time zone to '$zone':" >> $log_file
ln -sf /usr/share/zoneinfo/$zone /etc/localtime 2>&1 | tee -a $log_file

# HOSTNAME

echo ""
echo "Enter hostname (e.g. archbox):"
read hostname

echo ">>> Setting host name to '$hostname'." >> $log_file
echo "$hostname" > /etc/hostname

# USERS

echo ""
echo "Set password for root user:"
passwd

echo ""
echo "Enter user name (e.g. chris):"
read username

echo ">>> Creating user '$username':" >> $log_file
useradd -mg wheel $username 2>&1 | tee -a $log_file
passwd $username

echo ">>> Updating sudoers file." >> $log_file

sudoers_user_privilege_line="%wheel ALL=(ALL) ALL"
sed -i "/# $sudoers_user_privilege_line/s/^# //" /etc/sudoers

# GIT CONFIG

sudo -u $username git config --global credential.helper store

echo ""
echo "Enter git user name:"
read git_username
echo ""
echo "Enter git email:"
read git_email

sudo -u $username git config --global user.name "$git_username"
sudo -u $username git config --global user.email "$git_email"

# YAY

sudo -u $username git clone https://aur.archlinux.org/yay.git /home/$username/yay 2>&1 | tee -a $log_file
cd /home/$username/yay
sudo -u $username makepkg --noconfirm -si
rm -rf /home/$username/yay

# SIMPLE TERMINAL (ST)

st_git_repo="https://github.com/Chris-F5/MyStFork.git"
sudo -u $username git clone $st_git_repo /home/$username/st 2>&1 | tee -a $log_file

echo ">>> Installing st:" >> $log_file
cd /home/$username/st
make clean install 2>&1 | tee -a $log_file
echo "tput smkx" >> /home/$username/.bashrc

# DWM

dwm_git_repo="https://github.com/Chris-F5/MyDwmFork.git"
sudo -u $username git clone $dwm_git_repo /home/$username/dwm 2>&1 | tee -a $log_file

echo ">>> Installing dwm:" >> $log_file
cd /home/$username/dwm
make clean install 2>&1 | tee -a $log_file

pacman --noconfirm -Sy xorg-xsetroot 2>&1 | tee -a $log_file

echo "startx" >> /home/$username/.bash_profile

echo "setxkbmap $xorg_keymap" >> /home/$username/.xinitrc
echo "exec dwm" >> /home/$username/.xinitrc
chown $username:wheel /home/$username/.xinitrc

# DMENU

dmenu_git_repo="https://git.suckless.org/dmenu"
sudo -u $username git clone $dmenu_git_repo /home/$username/dmenu 2>&1 | tee -a $log_file

echo ">>> Installing dmenu:" >> $log_file
cd /home/$username/dmenu
make clean install 2>&1 | tee -a $log_file

# OPTIONAL PACKAGES

dev_packages="glfw-x11 vulkan-devel shaderc"
optional_packages="discord neofetch firefox man-db man-pages $dev_packages"

aur_packages="cglm"

echo ">>> Installing optional packages '$optional_packages':" >> $log_file
pacman --noconfirm -Sy $optional_packages 2>&1 | tee -a $log_file
sudo -u $username yay --noconfirm -Sy $aur_packages 2>&1 | tee -a $log_file

# NVIM

nvim_deps="neovim nodejs"
echo ">>> Installing neovim and dependencies '$nvim_deps':" >> $log_file
pacman --noconfirm -Sy $nvim_deps 2>&1 | tee -a $log_file
sudo -u $username mkdir -p /home/$username/.config/nvim
sudo -u $username git clone https://github.com/Chris-F5/NvimConfig.git /home/$username/.config/nvim
sudo -u $username nvim +"PlugInstall --sync" +qa
