#!/bin/sh
(
echo g # GTP partition

# EFI partition (UEFI systems only)
echo n
echo 1
echo ""
echo +550M

# Swap partition
echo n
echo 2
echo ""
echo +2G

echo t
echo 2
echo "Linux swap"

# Root partition
echo n
echo 3
echo ""
echo ""

# Write to disk
echo w

) | fdisk /dev/sda