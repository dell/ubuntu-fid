#!/usr/bin/python
#
#       <04-kernel.py>
#
#       If a new kernel package is available, this will query
#       the one on the installed system and identify if the newer one should
#       be installed.  All of this querying has to occur in case the person
#       happens to have a network cable plugged in during a "recovery" causing
#       a newer kernel to be pulled from -updates.
#
#       Copyright 2008-2009 Dell Inc.
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

#------------------------#
#Define new versions here#
#------------------------#
upstream_kernel    = "2.6.27"
kernel_abi         = "10"
kernel_ver_sub     = ".21"
meta_ver_sub       = ".13"
#------------------------#

kernel_version     = upstream_kernel + "-" + kernel_abi + kernel_ver_sub
kernel_type        = "generic"
kernel_arch        = "i386"
kernel_dir         = "/cdrom/debs/kernel"
kernel_pkg         = "linux-image-" + upstream_kernel + "-" + kernel_abi + "-" + kernel_type
kernel_files       = [
    kernel_dir + "/linux-libc-dev_" + kernel_version + "_" + kernel_arch + ".deb",
    kernel_dir + "/" + kernel_pkg + "_" + kernel_version + "_" + kernel_arch + ".deb",
    kernel_dir + "/linux-headers-" + upstream_kernel + "-" + kernel_abi + "_" + kernel_version + "_all.deb",
    kernel_dir + "/linux-headers-" + upstream_kernel + "-" + kernel_abi + "-" + kernel_type + "_" + kernel_version + "_" + kernel_arch + ".deb"]

meta_version       = upstream_kernel + '.' + kernel_abi + meta_ver_sub
meta_arch          = kernel_arch
meta_type          = kernel_type
meta_dir           = "/cdrom/debs/meta"
meta_pkg           = "linux"
meta_files         = [
    meta_dir + "/linux_" + meta_version + "_" + meta_arch + ".deb",
    meta_dir + "/linux-" + meta_type + "_" + meta_version + "_" + meta_arch + ".deb",
    meta_dir + "/linux-headers-" + meta_type + "_" + meta_version + "_" + meta_arch + ".deb",
    meta_dir + "/linux-image_" + meta_version + "_" + meta_arch + ".deb",
    meta_dir + "/linux-image-" + meta_type + "_" + meta_version + "_" + meta_arch + ".deb"]


inst_cmd=["dpkg","-i"]
remove_cmd=["apt-get","remove","--purge","-y","--force-yes"]

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

#now, we'll handle a meta update
if os.path.exists(meta_dir):
    inst_meta=True
else:
    inst_meta=False

if inst_meta:
    try:
        cached_package=cache[meta_pkg]
        inst_meta_version=cached_package.installedVersion
    except KeyError:
        print "Package " + meta_pkg + " " + meta_version + " isn't known to APT"
        cached_package=False

    if not cached_package or meta_version > inst_meta_version:
        print "Installing updated meta package, version " + meta_version
        for file in meta_files:
            if not os.path.exists(file):
                inst_meta=False
                print "Error, unable to find " + file + ". Ignoring package."
                break
        if inst_meta:
            inst_cmd.extend(meta_files)
    else:
        print "Package " +meta_pkg + " version " + meta_version + " or later is already installed"
        inst_meta=False

#Install the packages that were selected
if inst_kernel or inst_meta:
    ret=subprocess.call(inst_cmd)
    if ret != 0:
        sys.exit(1)

#Remove any old kernelsif inst_kernel:
if inst_kernel:
    for item in cache.keys():
        if ("linux-image-2.6" in item and kernel_type in item and kernel_abi not in item) or \
           ("linux-headers-2.6" in item and kernel_type in item and kernel_abi not in item):
            remove_cmd.append(item)
    ret=subprocess.call(remove_cmd)
    if ret != 0:
        sys.exit(2)
