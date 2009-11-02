#!/bin/bash
#
#       <45-incomplete-language-support.sh>
#
#       Works around bug 471553 that was found in Ubuntu 9.10 gold
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

. /cdrom/scripts/chroot-scripts/fifuncs ""

IFHALT "Working around bug 471553..."

if [ -f /var/lib/update-notifier/user.d/incomplete-language-support-gnome.note ]; then
    rm -f /var/lib/update-notifier/user.d/incomplete-language-support-gnome.note
fi
