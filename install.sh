#!/bin/bash

log_file="install.log"
printf "" > $log_file

# KEYMAP

#echo "Valid keymaps: "
#find /usr/share/kbd/keymaps -name "*.map.gz" -printf "%f\n" | sed -e "s/.map.gz//g"

keymap=uk

echo ">>> Loading keymap '$keymap':" >> $log_file
loadkeys $keymap 2>&1 | tee -a $log_file

# BOOT INFO

ls /sys/firmware/efi/efivars >/dev/null 2>&1 && boot_mode=UEFI || boot_mode=BIOS
echo "Boot mode: $boot_mode"
echo ">>> Boot mode: $boot_mode" >> $log_file

# TODO: CHECK NETWORK

# SYNC CLOCK

echo ">>> Synchronizing clock:" >> $log_file
timedatectl set-ntp true 2>&1 | tee -a $log_file

# SELECT DISK

echo "Available storage devices:"
echo ""

sfdisk -l | less

echo ""
echo "Enter disk name (e.g. '/dev/sda'): "
read disk

ls $disk >/dev/null 2>&1 || { echo "$disk does not exits. Exiting..." ; exit ;}

echo "!!! WARNING !!!"
echo "ARE YOU SURE YOU WANT TO INSTALL ONTO $disk"
echo "!!! WARNING !!!"
echo "Hit enter to continue."
read

echo ">>> Using disk: '$disk'" >> $log_file

echo "Wiping '$disk' please wait..."

echo ">>> Wiping '$disk' disk. (this should give an error 'No space left on device')" >> $log_file
dd if=/dev/zero of=$disk bs=1M >> $log_file 2>&1

default_boot_partition_size=512M
echo "Auto partition scheme: "
echo "    Partition type: dos"
echo "    Boot partition size: $default_boot_partition_size"
echo "    Root partition fills remaining space"

echo ">>> Automatically partitioning '$disk' disk:" >> $log_file

sfdisk $disk 2>&1 << EOF | tee -a $log_file
,$default_boot_partition_size 83 *
;
EOF

echo ">>> Formatting partitions:" >> $log_file
mkfs.ext4 ${disk}1 2>&1 | tee -a $log_file
mkfs.ext4 ${disk}2 2>&1 | tee -a $log_file

echo ">>> Mounting:" >> $log_file
mount ${disk}2 /mnt 2>&1 | tee -a $log_file
mkdir /mnt/boot
mount ${disk}1 /mnt/boot 2>&1 | tee -a $log_file

echo ">>> Pacstrap:" >> $log_file
required_base_packages="base base-devel linux linux-firmware"
pacstrap /mnt $required_base_packages 2>&1 | tee -a $log_file

echo ">>> fstab:" >> $log_file
genfstab -U /mnt > /mnt/etc/fstab 2>>$log_file
cat /mnt/etc/fstab >> $log_file

echo ">>> Chrooting into new install:" >> $log_file

cp sys_config.sh /mnt/sys_config.sh || { echo "Failed to copy sys_config.sh to new root. Check sys_config.sh is in your current path. Exiting..." ; exit ; }
chmod +x /mnt/sys_config.sh
mounted_log_file="/mounted_install.log"
arch-chroot /mnt /sys_config.sh $disk $mounted_log_file
cat /mnt$mounted_log_file >> $log_file
rm -f /mnt/sys_config.sh /mnt$mounted_log_file

echo ""
echo "Hit enter to unmount."
read

echo ">>> Unmount: " >> $log_file
umount -R /mnt 2>&1 | tee -a $log_file

echo "Install complete. Log file: '$log_file'"
