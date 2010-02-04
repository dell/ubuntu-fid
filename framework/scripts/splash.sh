#!/bin/sh
#
#       <splash.sh>
#
#       Provide hooks to output stuff to the display
#
#       Copyright 2010 Dell Inc.
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

#These provide base functions that may be overridden
. $ROOT/../lib/init/splash-functions-base

#These provide implementation specifics that are only needed if we really can splash
if grep -q splash /proc/cmdline; then
    . $ROOT/../lib/init/splash-functions
fi

try_splash_write()
{
    INPUT="$(printf "$1")"
    if splash_running; then
        plymouth message --text="$INPUT"
    else
        chvt 5
        printf "$INPUT\n" > /dev/console
    fi
}

try_splash_ask()
{
    INPUT="$(printf "$1")"
    if splash_running; then
        ANSWER=$(plymouth ask-question --prompt="$INPUT")
    else
        chvt 5
        printf "$INPUT" > /dev/console
        read -p ": " ANSWER > /dev/console 2>&1 < /dev/console
    fi
    echo "$ANSWER"
}

try_splash_quit()
{
    INPUT="$(printf "$1")"
    if splash_running; then
        plymouth message --text="$INPUT"
        plymouth quit --retain-splash
    else
        chvt 5
        clear
        printf "$INPUT\n" > /dev/console
        read x < /dev/console
    fi
}
