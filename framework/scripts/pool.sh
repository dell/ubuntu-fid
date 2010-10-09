#!/bin/sh
#
#       <pool.sh>
#
#       Builds a pool from important stuff in /cdrom
#       * Expects to be called as root w/ /cdrom referring to our stuff
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

[ -d /cdrom/debs ]

#This allows things that aren't signed to be installed
if [ ! -f /etc/apt/apt.conf.d/00AllowUnauthenticated ]; then
    cat > /etc/apt/apt.conf.d/00AllowUnauthenticated << EOF
APT::Get::AllowUnauthenticated "true";
Aptitude::CmdLine::Ignore-Trust-Violations "true";
EOF
fi

#Prevents apt-get from complaining about unmounting and mounting the hard disk
if [ ! -f /etc/apt/apt.conf.d/00NoMountCDROM ]; then
    cat > /etc/apt/apt.conf.d/00NoMountCDROM << EOF
APT::CDROM::NoMount "true";
Acquire::cdrom 
{
    mount "/cdrom";
    "/cdrom/" 
    {
        Mount  "true";
        UMount "true";
    };
    AutoDetect "false";
};
EOF
fi


#choose-mirror might not have picked a good mirror to start with
#https://bugs.launchpad.net/ubuntu/+source/choose-mirror/+bug/550694
sed -i "s/http:\/\/.*.archive.ubuntu.com/http:\/\/archive.ubuntu.com/" /etc/apt/sources.list

if [ ! -f /etc/apt/sources.list.d/dell.list ]; then
    #extra sources need to be disabled for this
    if find /etc/apt/sources.list.d/ -type f | grep sources.list.d; then
        mkdir -p /etc/apt/sources.list.d.old
        mv /etc/apt/sources.list.d/* /etc/apt/sources.list.d.old
    fi
    #Produce a dynamic list
    cd /cdrom/debs
    apt-ftparchive packages ../../cdrom/debs | sed "s/^Filename:\ ..\//Filename:\ .\//" > /Packages
    echo "deb file:/ /" > /etc/apt/sources.list.d/dell.list

    #add the static list to our file
    apt-cdrom -m add
    if grep "^deb cdrom" /etc/apt/sources.list >> /etc/apt/sources.list.d/dell.list; then
        sed -i "/^deb\ cdrom/d" /etc/apt/sources.list
    fi

    #fill up the cache
    mv /etc/apt/sources.list /etc/apt/sources.list.ubuntu
    apt-get update

    #cleanup
    mv /etc/apt/sources.list.ubuntu /etc/apt/sources.list
    rm -f /Packages
    if [ -d /etc/apt/sources.list.d.old ]; then
        mv /etc/apt/sources.list.d.old/* /etc/apt/sources.list.d
        rm -rf /etc/apt/sources.list.d.old
    fi
fi



