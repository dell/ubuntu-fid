#!/bin/sh
#
#       <chroot.sh>
#
#       Prepares the installed system for entering into postinstall phase
#       Calls the postinatll phase script (run_chroot)
#       Cleans up after postinstall completes
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

set -x
set -e

export BOOT_PART_NUM=3
export TARGET=/target

DEVICE=$(mount | sed -n 's/\ on\ \/cdrom.*//p')
export BOOTDEV=${DEVICE%%[0-9]*}
DEVICE=$(mount | sed -n 's/\ on\ \/target.*//p')
export TARGETDEV=${DEVICE%%[0-9]*}

LOG="var/log"
DPKG=dpkg
if [ -d "$TARGET/$LOG/installer" ]; then
    LOG="$LOG/installer"
fi
if [ -x /usr/bin/udpkg ]; then
    DPKG=udpkg
fi
export LOG

if [ -d "$TARGET/$LOG" ]; then
    exec > $TARGET/$LOG/chroot.sh.log 2>&1
fi
chroot $TARGET chattr +a $LOG/chroot.sh.log

echo "in $0"

if [ "$1" != "success" ]; then
    . /cdrom/scripts/chroot-scripts/FAIL-SCRIPT
    exit 1
fi

# Execute FAIL-SCRIPT if we exit for any reason (abnormally)
trap ". /cdrom/scripts/chroot-scripts/FAIL-SCRIPT" TERM INT HUP EXIT QUIT


# Install FIST and Nobulate Here.
# This way if we die early we'll RED Screen
if ls /cdrom/debs/fist/*.deb > /dev/null 2>&1; then
    if mount | grep "/root"; then
        umount /root
    fi
    if mount | grep "/mnt"; then
        umount /mnt
    fi
    $DPKG -i /cdrom/debs/fist/*.deb
    sync;sync
    [ -f /dell/fist/tal ] && /dell/fist/tal nobulate 0
fi

mount --bind /dev $TARGET/dev
MOUNT_CLEANUP="$TARGET/dev $MOUNT_CLEANUP"
if ! mount | grep "$TARGET/var/run"; then
    mount --bind /var/run $TARGET/var/run
    MOUNT_CLEANUP="$TARGET/var/run $MOUNT_CLEANUP"
fi
if ! mount | grep "$TARGET/proc"; then
    mount -t proc targetproc $TARGET/proc
    MOUNT_CLEANUP="$TARGET/proc $MOUNT_CLEANUP"
fi
if ! mount | grep "$TARGET/sys"; then
    mount -t sysfs targetsys $TARGET/sys
    MOUNT_CLEANUP="$TARGET/sys $MOUNT_CLEANUP"
fi

if ! mount | grep "$TARGET/media/cdrom"; then
    mount --bind /cdrom $TARGET/cdrom
    MOUNT_CLEANUP="$TARGET/cdrom $MOUNT_CLEANUP"
fi

#Run chroot scripts
chroot $TARGET /cdrom/scripts/chroot-scripts/run_chroot

for mountpoint in $MOUNT_CLEANUP;
do
    umount -l $mountpoint
done

sync;sync

# reset traps, as we are now exiting normally
trap - TERM INT HUP EXIT QUIT

. /cdrom/scripts/chroot-scripts/SUCCESS-SCRIPT
