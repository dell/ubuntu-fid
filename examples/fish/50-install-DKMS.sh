#!/bin/sh
#
#       <50-install-DKMS>
#
#       Adds DKMS to the system
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

. /mnt/scripts/chroot-scripts/fifuncs ""

IFHALT "Install DKMS now prior to installing any deb's"
if ls /mnt/debs/x7745/dkms*.deb  > /dev/null 2>&1; then
    dpkg -i /mnt/debs/x7745/*.deb
fi
IFHALT "Done with DKMS Install"
