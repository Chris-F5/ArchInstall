#!/bin/sh
# Mount root partition
mount /dev/sda3 /mnt

# Install arch linux
OPTIONAL_PACKAGES="vim"
pacstrap /mnt base linux linux-firmware $OPTIONAL_PACKAGES

# Generate file system table
genfstab -U /mnt >> /mnt/etc/fstab
