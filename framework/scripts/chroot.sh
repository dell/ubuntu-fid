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

exec > /target/var/log/installer/chroot.sh.log 2>&1
chattr +a /target/var/log/installer/chroot.sh.log

echo "in $0"

if [ "$1" != "success" ]; then
    . /cdrom/scripts/chroot-scripts/FAIL-SCRIPT
    exit 1
fi

# Execute FAIL-SCRIPT if we exit for any reason (abnormally)
trap ". /cdrom/scripts/chroot-scripts/FAIL-SCRIPT" TERM INT HUP EXIT QUIT

. /cdrom/scripts/environ.sh

# Install FIST and Nobulate Here.
# This way if we die early we'll RED Screen
if ls /cdrom/debs/fist/*.deb > /dev/null 2>&1; then
    dpkg -i /cdrom/debs/fist/*.deb
    sync;sync
    [ -f /dell/fist/tal ] && /dell/fist/tal nobulate 0
fi

mount -t proc targetproc /target/proc
mount -t sysfs targetsys /target/sys
mount --bind /cdrom /target/cdrom
mount --bind /dev /target/dev

# re-enable the cdrom for postinstall
sed -i 's/^#deb\ cdrom/deb\ cdrom/' /target/etc/apt/sources.list

chroot /target /cdrom/scripts/chroot-scripts/run_chroot

umount /target/cdrom
umount /target/proc
umount /target/sys
# we're having an issue umounting dev
# we'll try a lazy umount to detach the filesystem
umount -l /target/dev
sync;sync

# reset traps, as we are now exiting normally
trap - TERM INT HUP EXIT QUIT

. /cdrom/scripts/chroot-scripts/SUCCESS-SCRIPT
