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
chroot /root apt-get install dell-recovery -y

#only if we are in factory or bto-a
if chroot /root apt-cache show fist 2>/dev/null 1>/dev/null; then
    chroot /root apt-get install fist -y
fi

#Emergency installer fixes
if [ -e /root/cdrom/scripts/emergency.sh ]; then
    . /root/cdrom/scripts/emergency.sh
fi
