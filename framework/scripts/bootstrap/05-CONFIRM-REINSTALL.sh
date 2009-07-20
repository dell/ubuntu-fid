#!/bin/sh
#
#       <05-CONFIRM-REINSTALL.sh>
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

    #stop usplash (yes start stops it)
    #/root/etc/init.d/usplash start || true

    # already run one time... this must be a reinstall
    # ask the user
    set +x
    CORRECT_ANSWER="ERASE"

    if grep -q splash /proc/cmdline; then
    	/sbin/usplash_write "TIMEOUT 0"
    	/sbin/usplash_write "VERBOSE on"
		/sbin/usplash_write "TEXT-URGENT ---WARNING---"
        /sbin/usplash_write "TEXT-URGENT This operation will restore your system to the original factory"
    	/sbin/usplash_write "TEXT-URGENT configuration.  All personal files and changes will be lost."
    	/sbin/usplash_write "TEXT-URGENT That information will not be recoverable."
    	/sbin/usplash_write "TEXT-URGENT ALL DATA ON YOUR HARD DRIVE WILL BE PERMANENTLY LOST."
    	/sbin/usplash_write "INPUT To proceed, please type: $CORRECT_ANSWER.  "
    	answer=$(cat /dev/.initramfs/usplash_outfifo)
    else
        chvt 5
        echo -e "\n\n" > /dev/console
        echo -e "\n\n" > /dev/console
        echo -e "\n\n" > /dev/console
        echo -e "\n\n" > /dev/console
        echo -e "\n\n" > /dev/console
        echo -e 'WARNING!    WARNING!   WARNING!' > dev/console
        echo -e "" > /dev/console
        echo -e "This operation will restore your system to the original factory" > /dev/console
        echo -e "configuration. All personal files and changes on this system will be lost." > /dev/console
        echo -e "That information will not be recoverable." > /dev/console
        echo -e "" > /dev/console
        echo -e "ALL DATA ON YOUR HARD DRIVES WILL BE PERMANENTLY AND IRRETRIEVABLY DESTROYED IF YOU CONTINUE.\n" > /dev/console
        echo -e "" > /dev/console
        echo -e "To proceed with the reinstallation, please type: $CORRECT_ANSWER" > /dev/console
        read -p      "Type any other text to abort: " answer > /dev/console 2>&1 < /dev/console
	fi

    if [ "$answer" = "$CORRECT_ANSWER" ]; then
	    if grep -q splash /proc/cmdline; then
			/sbin/usplash_write "CLEAR"
			/sbin/usplash_write "TEXT-URGENT Continuing installation.  Hard drive erasure will"
			/sbin/usplash_write "TEXT-URGENT begin in 10 seconds. Power off system to abort"
			/sbin/usplash_write "TEXT-URGENT (last chance)"
			sleep 10
			/sbin/usplash_write "CLEAR"
			/sbin/usplash_write "TEXT-URGENT Installation in progress.  This process will take"
			/sbin/usplash_write "TEXT-URGENT between 15 to 60 minutes."
			/sbin/usplash_write "TEXT-URGENT "
			/sbin/usplash_write "TEXT-URGENT If your system loses power, the install will restart"
			/sbin/usplash_write "TEXT-URGENT from the beginning."
			/sbin/usplash_write "VERBOSE off"
		else
                        chvt 5
			echo -e "\n\n" > /dev/console
			echo "Continuing Installation. Hard Drive erasure begins in 10 seconds. Power off system to abort (last chance)..." > /dev/console
			sleep 10
			echo -e "\n\nInstallation in progress. The installation will take at least 15 minutes. It may take more time depending on the size of the hard drive. It usually takes approximately 5 minutes per 100GB of hard disk storage, plus 10 minutes.\n\n" > /dev/console
			echo -e "If your system loses power during install, install normally will restart from the beginning." > /dev/console
			echo -e "\n\n" > /dev/console
		fi
        set -x
        return
    fi

	if grep -q splash /proc/cmdline; then
		/sbin/usplash_write "CLEAR"
		/sbin/usplash_write "TEXT-URGENT Installation ABORTED.  System will reboot in 30 seconds"
		/sbin/usplash_write "TEXT-URGENT NO CHANGES HAVE BEEN MADE TO YOUR HARD DRIVE."
	else
                chvt 5
		echo "Installation ABORTED. System will reboot in 30 seconds." > /dev/console
		echo "" > /dev/console
		echo "NO CHANGES HAVE BEEN MADE TO THE HARD DISKS." > /dev/console
	fi
    sleep 30
    while true; do reboot -fn; done
fi
