#!/bin/bash
#
#       <60-fix-apt-source.sh>
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

IFHALT "Fixing apt sources..."

# comment out cdrom lines
perl -p -i -e 's/^(deb cdrom)/## \1/;' /etc/apt/sources.list

echo "deb http://ppa.launchpad.net/dell-team/ubuntu hardy main" >> /etc/apt/sources.list
echo "deb-src http://ppa.launchpad.net/dell-team/ubuntu hardy main" >> /etc/apt/sources.list
