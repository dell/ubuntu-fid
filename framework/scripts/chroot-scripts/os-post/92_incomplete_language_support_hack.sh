#!/bin/sh
#
#       <92-incomplete_language_support_hack.sh>
#
#       Works around Bug 290398 that was present in Ubuntu Intrepid.
#       Even with all languages preseeded, popups were coming up claiming
#       that some language support is missing
#
#       Copyright 2008 Dell Inc.
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

. /cdrom/scripts/chroot-scripts/fifuncs ""

IFHALT "Deactivate language support warning..."

if [ -f /var/lib/update-notifier/user.d/incomplete-language-support-gnome.note ]; then
    rm -f /var/lib/update-notifier/user.d/incomplete-language-support-gnome.note
fi
