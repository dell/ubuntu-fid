#!/usr/bin/python
#
#       <02-xorg-conf.py>
#
#       Sets up xorg.conf for any proprietary drivers from 01-graphics
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

xorg_conf='/etc/X11/xorg.conf'
jockey_conf='/var/cache/jockey/check'

nvidia_package="nvidia-glx-177"
fglrx_package="xorg-driver-fglrx"

import fileinput
import apt_pkg

apt_pkg.init()
cache=apt_pkg.GetCache()

try:
    nvidia=cache[nvidia_package].CurrentVer
except KeyError:
    nvidia=False

try:
    fglrx=cache[fglrx_package].CurrentVer
except KeyError:
    fglrx=False

if nvidia:
    driver="nvidia"
elif fglrx:
    driver="fglrx"

if nvidia or fglrx:
    #write our xorg.conf
    for line in fileinput.input(xorg_conf,inplace=1):
        print line[:-1]
        if 'Identifier\t"Configured Video Device' in line:
            print '\tDriver\t\t"'+driver+'"'
            if nvidia:
                print '\tOption\t\t"NoLogo"\t\t"True"'
                print '\tOption\t\t"IgnoreDisplayDevices"\t"TV"'
    fileinput.close()

    #Don't let jockey tell us about this driver
    jockey=open(jockey_conf,'a')
    jockey.write('seen kmod:' + driver +'\n')
    jockey.write('used kmod:' + driver +'\n')
    jockey.close()
