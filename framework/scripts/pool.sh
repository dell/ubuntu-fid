#!/bin/sh
#
#       <buildpool.sh>
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
cd /cdrom/debs

apt-ftparchive packages ../../cdrom/debs | sed "s/^Filename:\ ..\//Filename:\ .\//" > /Packages

mv /etc/apt/sources.list /etc/apt/sources.list.ubuntu
echo "deb file:/ /" > /etc/apt/sources.list.d/dell.list
grep "^deb cdrom" /etc/apt/sources.list.ubuntu >> /etc/apt/sources.list.d/dell.list

cat > /etc/apt/apt.conf.d/00AllowUnauthenticated << EOF
APT::Get::AllowUnauthenticated "true";
Aptitude::CmdLine::Ignore-Trust-Violations "true";
EOF

apt-get update

#choose-mirror might not have picked a good mirror to start with
sed -i "s/http:\/\/.*.archive.ubuntu.com/http:\/\/archive.ubuntu.com/" /etc/apt/sources.list.ubuntu

#cleanup
mv /etc/apt/sources.list.ubuntu /etc/apt/sources.list
rm -f /Packages
