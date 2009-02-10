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

nvidia_package="nvidia-glx-180"
fglrx_package="xorg-driver-fglrx"

import fileinput
import apt_pkg
import subprocess
import string

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
    jockey=open(jockey_conf,'a')
    jockey.write('seen xorg:nvidia-173\n')
    jockey.write('seen xorg:nvidia-180\n')
    jockey.write('used xorg:nvidia-180\n')
    jockey.close()
elif fglrx:
    driver="fglrx"
    jockey=open(jockey_conf,'a')
    jockey.write('seen xorg:fglrx\n')
    jockey.write('used xorg:fglrx\n')
    jockey.close()

if nvidia or fglrx:
    #write our xorg.conf
    for line in fileinput.input(xorg_conf,inplace=1):
        print line[:-1]
        if 'Identifier\t"Configured Video Device' in line:
            print '\tDriver\t\t"'+driver+'"'
            if nvidia:
                print '\tOption\t\t"NoLogo"\t\t"True"'
                print '\tOption\t\t"IgnoreDisplayDevices"\t"TV"'
        if fglrx and 'Device\t\t"Configured Video Device"' in line:
            print '\tDefaultDepth\t24'
    fileinput.close()

#Check for the case that we have two NV cards
#hybrid graphics is broke right now, see NV479891
if nvidia:
    count=0
    cards=[]
    output=string.split(subprocess.Popen(['lspci'],stdout=subprocess.PIPE).communicate()[0],'\n')
    for line in output:
        if line and 'VGA' in line and 'nVidia' in line:
            count=count+1
            cards.append(line)
    if count > 1:
        for card in cards:
            if "9200" not in card:
                for line in fileinput.input(xorg_conf,inplace=1):
                    print line[:-1]
                    if '\tOption\t\t"IgnoreDisplayDevices"\t"TV"' in line:
                        print '\tBusID\t\t"PCI:' + string.replace(string.split(card)[0],'.',':') + '"'
                fileinput.close()



