#!/usr/bin/python
#
#       <01-jockey-drivers.py>
#
#       Installs additional drivers using Jockey
#        In order to be able to support updated drivers in the factory
#        it will build an apt pool of updated drivers and register
#        them with apt prior to the Jockey run.  This ensures
#        that each driver only gets installed once
#
#       Copyright 2009 Dell Inc.
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
import os
import apt
import sys
import tempfile
import apt.cdrom
import atexit
import aptsources.sourceslist
import shutil

class ProcessJockey():

    def __init__(self):
        self.driver_root = '/cdrom/debs'
        self.supported_drivers = ['nvidia', 'fglrx', 'bcmwl']

    def check_need_injection(self):
        '''Determine what drivers need to be injected into the pool'''
        drivers = []
        for item in self.supported_drivers:
            if os.path.exists(os.path.join(self.driver_root,item)):
                drivers.append(item)
        return drivers

    def install_new_aliases(self,drivers):
        '''If new modaliases are available, install them right now
           so that they will be available to Jockey later in the process'''
        for driver in drivers:
            for item in os.listdir(os.path.join(self.driver_root,driver)):
                if 'modalias' in item:
                    ret = subprocess.Popen(['dpkg', '-i', os.path.join(self.driver_root,driver,item)], stdout=subprocess.PIPE)
                    output = ret.communicate()[0]
                    print output
                    code = ret.wait()
                    if (code != 0):
                        print "Failed to install modaliases package: " + item 
                        exit(code)

    def find_and_install_drivers(self):
        '''Uses jockey to detect and install necessary drivers'''

        #spawn jockey backend inside the chroot (if we let service activation do it, it would be outside the chroot)
        backend = subprocess.Popen(["/usr/share/jockey/jockey-backend"])
        code = backend.poll()
        if (code and code != 0):
            print "Error starting jockey backend"
            exit(code)
      
        #call out jockey detection algorithms
        ret = subprocess.Popen(["jockey-text", "-l", "-m", "nonfree"],stdout=subprocess.PIPE)
        output = ret.communicate()[0]
        code = ret.wait()
        if (code != 0):
            print "jockey returned a non-zero return code"
        output = output.split('\n')

        #Build and array of things to install
        install = []
        biggest_nv = ''
        for line in output:
            if len(line) > 0:
                if 'nvidia' in line:
                    if not biggest_nv or (biggest_nv and line.split()[0] > biggest_nv.split()[0]):
                        biggest_nv = line
                elif 'Disabled' in line:
                    print "Marking for installation: %s" % line.split()[0]
                    install.append(line.split()[0])

        #Append the selected nvidia driver
        if len(biggest_nv) > 0 and 'Disabled' in biggest_nv:
            print "Marking for installation: %s" % biggest_nv.split()[0]
            install.append(biggest_nv.split()[0])

        #Install any detected drivers
        if len(install) > 0:
            #Disable modprobe during installation
            fake_binaries = ['/sbin/modprobe',
                             '/usr/sbin/update-initramfs',
                             '/sbin/modinfo']
            for binary in fake_binaries:
                os.rename(binary, '%s.REAL' % binary)
                with open(binary, 'w') as f:
                    print >>f, """\
#!/bin/sh
echo 1>&2
echo 'Warning: Fake %s called, doing nothing.' 1>&2
exit 0""" % binary
                os.chmod(binary, 0755)

            #Perform installation
            for item in install:
                print "Installing: %s" % item
                ret = subprocess.Popen(["jockey-text", "-e", item, "-m", "nonfree"],stdout=subprocess.PIPE)
                output = ret.communicate()[0]
                code = ret.wait()
                if (code != 0):
                    print "Error installing: %s" % item

            #Re-enable fake binaries
            for binary in fake_binaries:
                os.rename('%s.REAL' % binary, binary)
            #Update initramfs now
            ret = subprocess.Popen(["update-initramfs", "-u"],stdout=subprocess.PIPE)
            output = ret.communicate()[0]
            code = ret.wait()
            if (code != 0):
                print "Error updating initramfs"

        else:
            print "No Jockey supported drivers necessary"

        backend.terminate()
        if code:
            exit(code)

if __name__ == "__main__":
    if os.path.exists('/usr/share/jockey/jockey-backend'):
        processor = ProcessJockey()
        drivers = processor.check_need_injection()
        if len(drivers) > 0:
            tmp_dir = tempfile.mkdtemp()
            processor.install_new_aliases(drivers)
        processor.find_and_install_drivers()
    else:
        print "Jockey isn't installed on target.  Unable to detect drivers"
