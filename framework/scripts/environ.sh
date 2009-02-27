#!/bin/sh
#
#       <environ.sh>
#
#       Sets up all common environment variables used in both
#       the preinstall (bootstrap) and postinstall (chroot) phases.
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

export ORIGPATH=$PATH
export PATH=$PATH:/tmp/scripts/bin
export LD_LIBRARY_PATH=/tmp/scripts/lib/

labels_to_try="install OS os $label"
devpath=/dev/disk/by-label

export UP_PART_NUM=1
export RP_PART_NUM=2
export BOOT_PART_NUM=3
export SWAP_PART_NUM=5

if grep -q DVDBOOT /proc/cmdline; then
    # Assume we are just blasting the recovery stuff on /dev/sda
    # since we don't actually know where the target drive is
    # with usb sticks on the system and what not
    INSTALL_PART="/dev/sda"
    export INSTALL_PART=${INSTALL_PART}$RP_PART_NUM
else
    # DVDBOOT cannot assume drive will be properly labelled
    echo "Waiting for system devices to initialize."
    label=
    while [ -z "$label" ]
    do
        for i in $labels_to_try
        do
            label=$i
            echo "  checking for install device: $devpath/$label"
            if [ -e $devpath/$label ]; then
                break
            fi
            label=
            sleep 3
        done
    done
    echo "got install device ($label), continuing..."
    export INSTALL_PART=/dev/disk/by-label/$(readlink $devpath/$label)
fi

export BOOT_PART=${INSTALL_PART%%[0-9]*}$BOOT_PART_NUM
export SWAP_PART=${INSTALL_PART%%[0-9]*}$SWAP_PART_NUM
export BOOTDEV=${INSTALL_PART%%[0-9]*}

