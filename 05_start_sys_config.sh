#!/bin/sh
cp sys_config.sh /mnt/tmp/sys_config.sh
arch-chroot /mnt /tmp/sys_config.sh
