#!/bin/sh
#
#       <bootstrap.sh>
#
#       Launches all preinstall (bootstrap) scripts before starting installation
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
# vim:ts=8:sw=8:et:tw=0

set -x
set -e

echo "in bootstrap.sh" > /dev/tty12

exec > /dev/tty1 2>&1
#exec > /root/tmp/bootstrap.sh.log 2>&1

echo "in $0"

# Execute FAIL-SCRIPT if we exit for any reason (abnormally)
trap ". /root/cdrom/scripts/bootstrap/FAIL-SCRIPT" TERM INT HUP EXIT QUIT

. /root/cdrom/scripts/environ.sh

for i in /root/cdrom/scripts/bootstrap/*.sh;
do
    echo "running bootstrap script: $i"  > /dev/tty12
    echo -n -e "\n\nrunning bootstrap script: $i\n"
    [ -e $i ] && . $i
done

# reset traps, as we are now exiting normally
trap - TERM INT HUP EXIT QUIT

. /root/cdrom/scripts/bootstrap/SUCCESS-SCRIPT
