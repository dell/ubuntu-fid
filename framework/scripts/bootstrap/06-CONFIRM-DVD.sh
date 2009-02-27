#!/bin/sh
#
#       <06-CONFIRM-DVD.sh>
#
#       Determines whether the user has booted from DVD
#       If so:
#           1) Wipes the rest of the disk
#           2) Copies the contents of the MBR
#           3) Populates the recovery partition
#           4) Modifies to recovery partition UUID
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

if grep -q DVDBOOT /proc/cmdline; then

    # drop original MBR back in
    dd if=/root/cdrom/mbr.bin of=$BOOTDEV

    # need to copy /dev files into chroot
    cp /dev /root -R -f

    # re-read partition table
    chroot /root/ sfdisk -R $BOOTDEV

    # delete partition 4
    chroot /root/ parted -s $BOOTDEV rm 4 || :
    echo 0,0,0 | chroot /root sfdisk -N4 ${BOOTDEV} --force  || :

    # delete partition 3
    chroot /root/ parted -s $BOOTDEV rm 3 || :
    echo 0,0,0 | chroot /root sfdisk -N3 ${BOOTDEV} --force  || :

    # recopy dev files in case they changed (yes, this can happen)
    cp /dev /root -R -f

    # restore file contents of UP
    cat /root/cdrom/upimg.bin | gzip -d -c | dd of=${BOOTDEV}${UP_PART_NUM}

    #create a recovery partition
    mkdir /tmp/mnt
    chroot /root mkfs.msdos -n install ${BOOTDEV}${RP_PART_NUM}
    mount -t vfat ${BOOTDEV}${RP_PART_NUM} /tmp/mnt
    cp /root/cdrom/grub /tmp/mnt -R

    #add a bootloader to recovery partition
    cd /
chroot /root grub <<-EOF
    root (hd0,1)
    setup (hd0,1)
    quit
EOF

    # make recovery partition bootable
    chroot /root sfdisk -A${RP_PART_NUM} ${BOOTDEV}

    #Copy files into recovery partition
    cp /root/cdrom/* /tmp/mnt -R
    cp /root/cdrom/.disk /tmp/mnt -R

    #create a new UUID for the partition we
    #are dropping down to allow the user to
    #use this cd still to recover the system
    mount --bind /tmp/mnt /root/mnt
    chroot /root casper-new-uuid /cdrom/casper/initrd.gz /mnt/casper /mnt/.disk

    #clean up
    umount /root/mnt
    umount /tmp/mnt
    sync
    #eject the disk
    eject -p -m /cdrom >/dev/null 2>&1 || true

    #tell the user to reboot
    if grep -q splash /proc/cmdline; then
        /sbin/usplash_write "TIMEOUT 0"
        /sbin/usplash_write "VERBOSE on"
	/sbin/usplash_write "CLEAR"
        /sbin/usplash_write "TEXT-URGENT Please remove this DVD OR USB stick"
        /sbin/usplash_write "TEXT-URGENT and press enter to reboot."
	/sbin/usplash_write "PROGRESS 100"
    else
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e ""
        echo -e ""Please remove this DVD OR USB stick""
        echo -e ""and press enter to reboot""
    fi
    read x < /dev/console
    reboot -n
fi
