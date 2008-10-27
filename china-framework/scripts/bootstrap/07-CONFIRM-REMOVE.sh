#!/bin/sh

if grep -q REMOVE /proc/cmdline; then
	# already run one time... this must be a remove
	# ask the user
	# Remove all parts save N1
        DRIVE=/dev/sda
        if [ ! -e $DRIVE ]; then break; fi
        echo "0,0,0,-" | sfdisk -uS -N2 --force --no-reread $DRIVE
        echo "0,0,0,-" | sfdisk -uS -N3 --force --no-reread $DRIVE
        echo "0,0,0,-" | sfdisk -uS -N4 --force --no-reread $DRIVE

        echo "Operating System has been removed. The system is now unbootable. You must reinstall an operating system for the computer."
        sleep 600000 
fi
