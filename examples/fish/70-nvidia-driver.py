#!/usr/bin/python
#
#       <70-nvidia-driver.py>
#
#       Sets up an nvidia driver for a system.
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


import fileinput
import os

xorg_conf='/etc/X11/xorg.conf'
jockey_conf='/var/cache/jockey/check'
path='/mnt/debs/nvidia/'

###install nvidia deb and depends
#Install the version directly from
#the archive
#os.system('apt-get -y install nvidia-glx-new')

#Install the version shipped here
os.system('gdebi -n ' + path + 'nvidia-new-kernel-source*.deb')
os.system('dpkg -i ' + path + 'nvidia-glx-new*.deb')

#Add nvidia to xorg.conf
for line in fileinput.input(xorg_conf,inplace=1):
    print line[:-1]
    if 'Identifier\t"Configured Video Device' in line:
        print '\tDriver\t\t"nvidia"'
        print '\tOption\t\t"NoLogo"\t\t"True"'
        print '\tOption\t\t"IgnoreDisplayDevices"\t"TV"'
fileinput.close()
xorg=open(xorg_conf,'a')
xorg.write('\n')
xorg.write('Section "Module"\n')
xorg.write('\tLoad\t\t"glx"\n')
xorg.write('EndSection\n')
xorg.close()

#Don't let jockey tell us about this driver
jockey=open(jockey_conf,'a')
jockey.write('seen kmod:nvidia_new\n')
jockey.write('used kmod:nvidia_new\n')
jockey.close()
