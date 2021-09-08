#!/bin/bash

disk=$1

echo "Hit enter to install packages."
read

required_packages="networkmanager grub"
optional_packages="neovim neofetch"

pacman -S $required_packages $optional_packages

echo ""
echo "Hit enter to enable network manager."
read

systemctl enable NetworkManager

echo ""
echo "Hit enter to install grub."
read

grub-install $disk

echo ""
echo "Hit enter to make grub config."
read

grub-mkconfig -o /boot/grub/grub.cfg

echo ""
echo "Hit enter to set a password for root user."
read

passwd

echo ""
echo "Hit enter to generate locals."

locale="en_GB.UTF-8"
echo "Using locale '$locale'"

sed "s/#$locale/$locale/g" /etc/locale.gen > /etc/locale.gen
locale-gen
echo "LANG=$locale" > /etc/locale.conf

echo ""
echo "Enter hostname (e.g. archbox)"
read hostname

echo "$hostname" > /etc/hostname

echo "Hit enter to set time zone."
read

zone="Europe/London"
ln -sf /usr/share/zoneinfo/$zone /etc/localtime
