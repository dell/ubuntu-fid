#!/bin/sh
#
#       <emergency.sh>
#
#       Applies any emergency fixes for the installer that couldn't be fixed
#       upstream at this time
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
# vim:ts=8:sw=8:et:tw=0

#See https://bugs.launchpad.net/bugs/532961 for more details
sed -i "s/if\ priority\ ==\ 'critical'/from ubiquity import misc\n\ \ \ \ \ \ \ \ \ \ \ \ misc.execute_root\('partx',\ '-a',\ '\/dev\/sda'\)\n\ \ \ \ \ \ \ \ \ \ \ \ return\ True\n\ \ \ \ \ \ \ \ \ \ \ \ if\ priority\ ==\ 'critical'/" /root/usr/lib/ubiquity/ubiquity/components/partman_commit.py
