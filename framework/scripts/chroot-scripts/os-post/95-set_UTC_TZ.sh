#!/bin/sh
#
#       <95-set_UTC_TZ.sh>
#
#      This Script will run only once -AND-
#       Will be removed by the SUCCESS script

#       This script will update Local Time To UTC(GMT)
#       The offsets in the dictionary below were lifted
#       from the file tztable.xpe used by our sister group.
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


# *********** Warning ***************
# the time offset for ICC tz_offset.py was adjusted
# from 5:30 to 5
# ==== Do we need to change this???


# Copy /mnt/misc/tz_offset.py to /etc/init.d/tz_offset.py
cp -f /mnt/misc/tz_offset.py /etc/init.d/tz_offset.py
cp -f /mnt/misc/run-tz-fix /etc/init.d/run-tz-fix
chmod +x /etc/init.d/tz_offset.py
chmod +x /etc/init.d/run-tz-fix
# link it to /etc/rc2.d/S02_force_utc
ln -s /etc/init.d/run-tz-fix /etc/rc2.d/S02_force_utc
