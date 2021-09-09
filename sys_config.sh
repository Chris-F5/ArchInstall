#!/bin/bash

disk=$1
log_file=$2

printf "" > $log_file

packages="networkmanager grub neovim neofetch git"

echo "Installing packages '$packages':"
echo ">>> Installing packages '$packages':" >> $log_file
echo "yes" | pacman -Sy $packages 2>&1 | tee -a $log_file

echo ">>> Enabling network manager: " >> $log_file
systemctl enable NetworkManager 2>&1 | tee -a $log_file

echo "Installing grub:"
echo ">>> Installing grub:" >> $log_file
grub-install $disk 2>&1 | tee -a $log_file
grub-mkconfig -o /boot/grub/grub.cfg 2>&1 | tee -a $log_file

echo ""
echo "Set password for root user:"
passwd

locale="en_GB.UTF-8"
echo "Using locale '$locale'"

echo ">>> Setting locale to '$locale':" >> $log_file

sed -i "/^#$locale/s/^#//" /etc/locale.gen
locale-gen 2>&1 | tee -a $log_file
echo "LANG=$locale" > /etc/locale.conf

echo ""
echo "Enter hostname (e.g. archbox)"
read hostname

echo ">>> Setting host name to '$hostname'." >> $log_file
echo "$hostname" > /etc/hostname

zone="Europe/London"
echo ">>> Setting time zone to '$zone':" >> $log_file
ln -sf /usr/share/zoneinfo/$zone /etc/localtime 2>&1 | tee -a $log_file

echo ""
echo "Enter user name (e.g. chris):"
read username

echo ">>> Creating user '$username':" >> $log_file
useradd -mg wheel $username 2>&1 | tee -a $log_file
passwd $username

echo ">>> Updating sudoers file." >> $log_file

sudoers_user_privilege_line="%wheel ALL=(ALL) ALL"
sed -i "/# $sudoers_user_privilege_line/s/^# //" /etc/sudoers

echo ">>> Cloning dwm:" >> $log_file

dwm_git_repo="https://git.suckless.org/dwm"
git clone $dwm_git_repo 2>&1 | tee -a $log_file
