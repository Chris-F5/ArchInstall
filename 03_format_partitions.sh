#!/bin/sh
# Format EFI partition
mkfs.fat -F -F32 /dev/sda1

# Format swap partition
mkswap /dev/sda2
swapon /dev/sda2

# Format root partition
mkfs.ext4 -F /dev/sda3
