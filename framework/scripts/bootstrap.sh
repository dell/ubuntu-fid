#!/bin/sh
#
#       <bootstrap.sh>
#
#       Loads the ubiquity dell bootstrap plugin into place
#
#       Copyright 2008-2010 Dell Inc.
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
# vim:ts=8:sw=8:et:tw=0

#Build custom pool (static and dynamic)
chroot /root /cdrom/scripts/pool.sh

#shows our bootstrap page
chroot /root apt-get install dell-recovery -y --no-install-recommends

#only if we are in factory or bto-a
if chroot /root apt-cache show fist 2>/dev/null 1>/dev/null; then
    chroot /root apt-get install fist -y
else
#recovery media or hand install - double check dell-recovery version
#if we have a version targeted at a different ubuntu release, show a warning
    our_os_version=$(cat /root/etc/lsb-release | grep CODENAME | awk -F'=' '{ print $2 }')
    dell_recovery_os_version=$(zcat /root/usr/share/doc/dell-recovery/changelog.gz | /root/usr/bin/head -n 1)
    if [ -f /root/cdrom/misc/dell-unsupported.py ] && \
       echo $dell_recovery_os_version | grep -v $our_os_version >/dev/null && \
       grep "dell-recovery/recovery_type" /proc/cmdline >/dev/null; then
        cp /root/cdrom/misc/dell-unsupported.py /root/usr/lib/ubiquity/plugins
    fi
fi

#Emergency installer fixes
if [ -e /root/cdrom/scripts/emergency.sh ]; then
    . /root/cdrom/scripts/emergency.sh
fi
