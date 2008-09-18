#!/bin/sh
#
#       <01-graphics.sh>
#
#       Installs a graphics driver, either from FISH (If added)
#       or directly from an Ubuntu DVD (if available)
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

#First, lets check for NVIDIA graphics
if `lspci | grep VGA | grep nVidia >/dev/null`; then
	#If we have newer nvidia drivers, we can get them from here
	if [ -d /cdrom/debs/nvidia ]; then
		gdebi -n /cdrom/debs/nvidia/*kernel-source*.deb
		gdebi -n /cdrom/debs/nvidia/nvidia-glx*.deb
	#We don't have newer drivers, lets install from the DVD
	else
		apt-get install nvidia-glx-177 -y
	fi

#Next, we'll check for AMD/ATI:
elif `lspci | grep VGA | grep AMD >/dev/null`; then
	#If we have newer AMD drivers, we can get them from here
	if [ -d /cdrom/debs/fglrx ]; then
		gdebi -n /cdrom/debs/fglrx/*kernel-source*.deb
		gdebi -n /cdrom/debs/fglrx/xorg-driver-fglrx*.deb

#	<---- The AMD DVD check is turned off until the driver is functional ---->
#	#We don't have newer drivers, lets install from the DVD
#	else
#		apt-get install xorg-driver-fglrx -y
	fi
fi
