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

    # /root/dev and /dev need to be in sync while we do this file
    mount -o bind /dev /root/dev

    #size of our UP, in bytes
    utility_partition_size=`chroot /root gzip -l --quiet /cdrom/upimg.bin | awk '{ print \$2 }'`
    #size of our UP, in Mbytes (for fdisk)
    utility_partition_size=$((utility_partition_size/1048576))

    #size of our RP in kbytes
    recovery_partition_size=`chroot /root du -s /cdrom | cut -f1`
    #size of our RP in MBytes with some 300M cushion (for fdisk)
    recovery_partition_size=$((recovery_partition_size/1024 + 300))

    #clear partition table up
    dd if=/dev/zero of=${BOOTDEV} bs=512 count=2

    #partitioning activities
    # create UP
    # set UP to type de
    # create RP
    # set RP to type vfat
    # set RP to bootable
    chroot /root/ fdisk ${BOOTDEV} <<EOF
n
p
${UP_PART_NUM}

+${utility_partition_size}M
t
de

n
p
${RP_PART_NUM}

+${recovery_partition_size}M

t
p
${RP_PART_NUM}
0b

a
${RP_PART_NUM}

w
EOF

    #install a bootloader to MBR
    dd if=/root/usr/lib/syslinux/mbr.bin of=${BOOTDEV} bs=446 count=1 conv=sync

    # restore file contents of UP
    cat /root/cdrom/upimg.bin | gzip -d -c | dd of=${BOOTDEV}${UP_PART_NUM}

    #create a recovery partition
    chroot /root mkfs.msdos -n install ${BOOTDEV}${RP_PART_NUM}
    mount -t vfat ${BOOTDEV}${RP_PART_NUM} /root/mnt

    #Copy files into recovery partition
    cp /root/cdrom/* /root/cdrom/.disk /root/mnt -R

    #add a bootloader to recovery partition
    cd /
chroot /root grub <<-EOF
    root (hd0,1)
    setup (hd0,1)
    quit
EOF

    #create a new UUID for the partition we
    #are dropping down to allow the user to
    #use this cd still to recover the system
    chroot /root casper-new-uuid /cdrom/casper/initrd.gz /mnt/casper /mnt/.disk

    #clean up
    umount /root/dev
    umount /root/mnt
    sync

    #eject the disk
    eject -p -m /cdrom >/dev/null 2>&1 || true

    #tell the user to reboot
    if grep -q splash /proc/cmdline; then
        /sbin/usplash_write "TIMEOUT 0"
        /sbin/usplash_write "VERBOSE on"
        /sbin/usplash_write "CLEAR"
        /sbin/usplash_write "PROGRESS 100"
        /sbin/usplash_write "INPUTENTER Please remove this recovery media and press enter to reboot."
        answer=$(cat /dev/.initramfs/usplash_outfifo)
    else
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e "\n\n"
        echo -e ""
        echo -e ""Please remove this recovery media and press enter to reboot""
        read x < /dev/console
    fi
    reboot -n
fi
