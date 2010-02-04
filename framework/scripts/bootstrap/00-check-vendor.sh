#!/bin/sh
#
#       <00-check-vendor.sh>
#
#       Ensures that recovery media is running on a Dell system
#
#       Copyright 2009 Dell Inc.
#           Mario Limonciello <Mario_Limonciello@Dell.com>
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


if ! chroot /root dmidecode | grep -i "Vendor: Dell" 2>&1 >/dev/null &&
   ! chroot /root dmidecode | grep -i "Vendor: innotek" 2>&1 >/dev/null; then
    try_splash_write \
"This disk is only valid for Dell systems.
Rebooting system in 30 seconds."
    sleep 30
    while true; do reboot -fn; done
fi
