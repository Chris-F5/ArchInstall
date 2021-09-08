#!/bin/bash

# KEYMAP

echo "Hit enter to show valid keymaps."
read

echo "Valid keymaps: "
find /usr/share/kbd/keymaps -name "*.map.gz" -printf "%f\n" | sed -e "s/.map.gz//g"

echo ""
echo "Hit enter to set keymap."
read

keymap=uk

echo "Using keymap '$keymap'"
loadkeys $keymap

# BOOT INFO

echo ""
echo "Hit enter to show boot mode."
read

ls /sys/firmware/efi/efivars >/dev/null 2>/dev/null && echo "Booting in UEFI mode" || echo "Booting in BIOS mode"

# TODO: CHECK NETWORK

# SYNC CLOCK

echo ""
echo "Hit enter to synchronize clock."
read

timedatectl set-ntp true

# SELECT DISK

echo ""
echo "Hit enter to show available storage devices"
read

echo "Available storage devices:"
echo ""

sfdisk -l

echo ""
echo "Enter disk name (e.g. '/dev/sda'): "
read disk

ls $disk >/dev/null 2>/dev/null || { echo "$disk does not exits. Exiting..." ; exit ;}

echo "!!! WARNING !!!"
echo "ARE YOU SURE YOU WANT TO INSTALL ONTO $disk"
echo "!!! WARNING !!!"
echo "Hit enter to continue."
read

echo "Hit enter to wipe $disk"
read

echo "Wiping $disk please wait"
dd if=/dev/zero of=$disk bs=1M

echo ""
echo "Hit enter to show auto partition scheme"
read

default_boot_partition_size=512M
echo "Auto partition scheme: "
echo "    Partition type: dos"
echo "    Boot partition size: $default_boot_partition_size"
echo "    Root partition fills remaining space"

echo ""
echo "Hit enter to partition $disk"
read

echo "Automatically partitioning $disk"

sfdisk $disk << EOF
,$default_boot_partition_size 83 *
;
EOF

echo ""
echo "Hit enter to format partitions."
read

echo "Formatting partitions..."
mkfs.ext4 ${disk}1
mkfs.ext4 ${disk}2

echo ""
echo "Hit enter to mount disk."
read

mount ${disk}2 /mnt
mkdir /mnt/boot
mount ${disk}1 /mnt/boot

echo ""
echo "Hit enter to install arch with base packages."
read

required_base_packages="base base-devel linux linux-firmware"
pacstrap /mnt $required_base_packages

echo ""
echo "Hit enter to create fstab."
read

genfstab -U /mnt > /mnt/etc/fstab

echo ""
echo "Hit enter to change root to new system and continue setup."
read

cp sys_config.sh /mnt/sys_config.sh || { echo "Failed to copy sys_config.sh to new root. Check sys_config.sh is in your current path. Exiting..." ; exit ; }
chmod +x /mnt/sys_config.sh
arch-chroot /mnt /sys_config.sh $disk
rm -f /mnt/sys_config.sh

echo ""
echo "Hit enter to unmount new arch install."
read

umount -R /mnt

echo ""
echo "Hit enter to reboot."
read

reboot
