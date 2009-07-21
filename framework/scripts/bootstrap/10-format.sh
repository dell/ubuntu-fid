#!/bin/sh
#
#       <10-format.sh>
#
#       Formats partitions prior to installation to ensure that oem.seed
#       properly represents the system
#
#       Copyright 2008 Dell Inc.
#           Mario Limonciello <Mario_Limonciello@Dell.com>
#           Hatim Amro <Hatim_Amro@Dell.com>
#           Michael E Brown <Michael_E_Brown@Dell.com>
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

if ! grep -q INTERACTIVE /proc/cmdline; then
    # /root/dev and /dev need to be in sync while we do this file
    mount -o bind /dev /root/dev

    # Mark RP bootable
    chroot /root sfdisk -A${RP_PART_NUM} ${BOOTDEV}

    # * Delete partitions 3 & 4 since that's where we are installing to
    chroot /root/ parted -s ${BOOTDEV} rm 3 || :
    chroot /root/ parted -s ${BOOTDEV} rm 4 || :

    # Install grub onto the RP
    mount -t vfat ${BOOTDEV}${RP_PART_NUM} /root/boot
    chroot /root grub-install ${BOOTDEV}${RP_PART_NUM}

    # Cleanup
    umount /root/boot
    umount /root/dev
fi
