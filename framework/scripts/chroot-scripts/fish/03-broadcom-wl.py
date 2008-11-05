#!/usr/bin/python
#
#       <03-broadcom-wl.py>
#
#       Prevents Jockey from needing to offer Broadcom when it's 
#       already enabled
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

import subprocess

jockey_conf='/var/cache/jockey/check'

output=subprocess.Popen(['lsmod'],stdout=subprocess.PIPE).communicate()
for line in output:
    if line and 'wl' in line:
        jockey=open(jockey_conf,'a')
        jockey.write('seen kmod:wl\n')
        jockey.close()
        break
