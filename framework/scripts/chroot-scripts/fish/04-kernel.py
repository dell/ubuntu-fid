#!/usr/bin/python
#
#       <04-kernel.py>
#
#       If a new kernel or restricted package is available, this will query
#       the one on the installed system and identify if the newer one should
#       be installed.  All of this querying has to occur in case the person
#       happens to have a network cable plugged in during a "recovery" causing
#       a newer kernel to be pulled from -updates.
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

import warnings
from warnings import warn
warnings.filterwarnings("ignore", "apt API not stable yet", FutureWarning)
import apt
import os
import sys
import subprocess

kernel_abi     = "2.6.27-8"
kernel_version = kernel_abi + ".17"
kernel_type    = "generic"
kernel_arch    = "i386"
kernel_dir     = "/cdrom/debs/kernel"
kernel_pkg     = "linux-image-" + kernel_abi + "-" + kernel_type
kernel_files   = [
    kernel_dir + "/linux-libc-dev_" + kernel_version + "_" + kernel_arch + ".deb",
    kernel_dir + "/" + kernel_pkg + "_" + kernel_version + "_" + kernel_arch + ".deb",
    kernel_dir + "/linux-headers-" + kernel_abi + "_" + kernel_version + "_all.deb",
    kernel_dir + "/linux-headers-" + kernel_abi + "-" + kernel_type + "_" + kernel_version + "_" + kernel_arch + ".deb"]

restricted_version = kernel_abi + ".13"
restricted_arch    = kernel_arch
restricted_dir     = "/cdrom/debs/restricted"
restricted_pkg     = "linux-restricted-modules-" + kernel_abi + "-" + kernel_type
restricted_files   = [
    restricted_dir + "/linux-restricted-modules-" + kernel_abi + "-" + kernel_type + "_" + restricted_version + "_" + restricted_arch + ".deb",
    restricted_dir + "/linux-restricted-modules-common_" + restricted_version + "_all.deb" ]

inst_cmd=["dpkg","-i"]

#Initialize apt cache
cache=apt.Cache()

#First we'll handle a kernel update
if os.path.exists(kernel_dir):
    inst_kernel=True
else:
    inst_kernel=False

if inst_kernel:
    try:
        cached_package=cache[kernel_pkg]
        inst_kernel_version=cached_package.installedVersion
    except KeyError:
        print "Package " + kernel_pkg + " " + kernel_version + " isn't known to APT" 
        cached_package=False
    
    if not cached_package or kernel_version > inst_kernel_version:
        print "Installing updated kernel image, version " + kernel_version
        for file in kernel_files:
            if not os.path.exists(file):
                inst_kernel=False
                print "Error, unable to find " + file + ". Ignoring package."
                break
        if inst_kernel:
            inst_cmd.extend(kernel_files)
    else:
        print "Package " + kernel_pkg + " version " + kernel_version + " or later is already installed"
        inst_kernel=False

#next we'll handle a LRM update
if os.path.exists(restricted_dir):
    inst_restricted=True
else:
    inst_restricted=False

if inst_restricted:
    try:
        cached_package=cache[restricted_pkg]
        inst_restricted_version=cached_package.installedVersion
    except KeyError:
        print "Package " + restricted_pkg + " " + restricted_version + " isn't known to APT" 
        cached_package=False

    if not cached_package or restricted_version > inst_restricted_version:
        print "Installing updated restricted package, version " + restricted_version
        for file in restricted_files:
            if not os.path.exists(file):
                inst_restricted=False
                print "Error, unable to find " + file + ". Ignoring package."
                break
        if inst_restricted:
            inst_cmd.extend(restricted_files)
    else:
        print "Package " + restricted_pkg + " version " + restricted_version + " or later is already installed"
        inst_restricted=False


if inst_kernel or inst_restricted:
    ret=subprocess.call(inst_cmd)
    if ret != 0:
        sys.exit(1)
