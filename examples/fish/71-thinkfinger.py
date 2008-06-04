#!/usr/bin/python
#
#       <71-thinkfinger.py>
#
#       Sets up a thinfinger supported fingerprint reader
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

pam_conf='/etc/pam.d/common-auth'

#install thinkfinger deb and depends
#these are right on the DVD already
os.system('apt-get -y install thinkfinger-tools libpam-thinkfinger')

#Replace auth lines
for line in fileinput.input(pam_conf,inplace=1):
    if 'auth\trequisite\tpam_unix.so nullok_secure' in line:
        print '#auth\trequisite\tpam_unix.so nullok_secure'
        print 'auth\tsufficient\tpam_thinkfinger.so'
        print 'auth\trequisite\tpam_unix.so try_first_pass nullok_secure'
    else:
        print line[:-1]
fileinput.close()
