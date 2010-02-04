#!/bin/sh
#
#       <05-confirm-erase.sh>
#
#       Queries the user to perform the reinstallation.
#       All steps beyond this step may be destructive.
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

# Check for partition 3 or for if this is really a REINSTALL.
# If they don't exist then we don't need to ask to clear them!
if grep -q DVDBOOT /proc/cmdline || ( grep -q REINSTALL /proc/cmdline && [ -e $BOOT_PART ] ); then

    CORRECT_ANSWER="ERASE"

    ANSWER=$(try_splash_ask \
">>WARNING<<
This operation will restore your system to the original factory configuration.
All personal files and changes will be lost.
To proceed, please type: $CORRECT_ANSWER")

    if [ "$ANSWER" = "$CORRECT_ANSWER" ]; then
        try_splash_write \
"Continuing installation.  Hard drive erasure will begin in 10 seconds.
Power off system to abort.
(last chance)"

        sleep 10

        try_splash_write \
"Installation in progress.

Please be patient, as this process will take between 15-60 minutes.
If your system loses power, the install will restart from the beginning."

        return
    fi

    try_splash_write \
"Installation ABORTED.
System will reboot in 30 seconds.

NO CHANGES HAVE BEEN MADE TO YOUR HARD DRIVE."

    sleep 30
    while true; do reboot -fn; done
fi
