#!/usr/bin/python
#
#       <01-build-apt-archive.py>
#
#
#       Builds an apt archive of things in debs/
#        This allows them to have proper dependency resolution
#        and for things in the main pool to still trump them.
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

import tempfile
import os
import apt
import apt.cdrom
import aptsources.sourceslist
import shutil

class BuildBTOArchive():

    def __init__(self):
        self.driver_root = '/cdrom/debs'

    def prepare_pool(self, directory):
        '''Prepares the temp pool for new debs
           directory: a two level root directory (eg /a/b)'''

        #make a nice symlink
        os.symlink(self.driver_root, directory)

        #build the packages file
        ret = subprocess.Popen(['apt-ftparchive', 'packages' os.path.split(directory)[1],], cwd=os.path.split(directory)[0], stdout=subprocess.PIPE)
        output = ret.communicate()[0]
        code = ret.wait()
        if (code != 0):
            print "failed to write updated package lists for injected packages"
            exit(code)
        if os.path.exists(os.path.join(directory, 'Packages')):
            os.remove(os.path.join(directory, 'Packages'))
        file = open(os.path.join(directory, 'Packages'),'w')
        file.write(output)
        file.close()

    def toggle_sources_list(self,enable,directory=None):
        '''Toggles if an apt source is enabled'''
        #add to sources.list
        
        if enable:
            if directory:
                #move old sources.list out of the way
                shutil.move('/etc/apt/sources.list','/etc/apt/sources.list.bto')
                #create a new sources.list
                open('/etc/apt/sources.list','w').close()
                sources = aptsources.sourceslist.SourcesList()
                sources.add('deb','file:' + os.path.split(directory)[0], os.path.split(directory)[1] + '/', [])
                sources.save()
                cdrom = apt.cdrom.Cdrom()
                cdrom.add()
                #update apt cache with local sources only
                cache = apt.Cache()
                print cache.update(apt.progress.TextFetchProgress())
            else:
                print "Error, must provide a directory to enable"
        elif os.path.exists('/etc/apt/sources.list.bto'):
            shutil.move('/etc/apt/sources.list.bto','/etc/apt/sources.list')

if __name__ == "__main__":
    archive = BuildBTOArchive()
    tmp_dir = tempfile.mkdtemp()

    archive.prepare_pool(tmp_dir)
    archive.toggle_sources_list(True, tmp_dir)
    atexit.register(archive.toggle_sources_list,False)
