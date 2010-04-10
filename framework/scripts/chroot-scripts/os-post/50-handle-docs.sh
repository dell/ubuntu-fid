#!/bin/bash
#
#       <50-handle-docs.sh>
#
#       Copies important documents to a folder on the user's desktop
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

. /usr/share/dell/scripts/fifuncs ""

IFHALT "Copying Vendor Documents..."

if [ -d /cdrom/docs ] && [ "$(ls -A /cdrom/docs)" ]; then
        mkdir -p /usr/share/doc/dell
    cp -a /cdrom/docs/* /usr/share/doc/dell
    [ ! -d "/etc/skel/Desktop" ] && mkdir -p /etc/skel/Desktop
    ln -s /usr/share/doc/dell /etc/skel/Desktop
fi

IFHALT "Done with copying vendor documents..."
