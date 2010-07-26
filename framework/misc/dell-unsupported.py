# -*- coding: utf-8; Mode: Python; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2010 Dell Inc.
#
# Ubiquity is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Ubiquity is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ubiquity.  If not, see <http://www.gnu.org/licenses/>.

from ubiquity.plugin import PluginUI

NAME = 'dell-unsupported'
AFTER = None
WEIGHT = 100

class PageGtk(PluginUI):
    def __init__(self, *args, **kwargs):
        import gtk
        label = gtk.Label()
        label.set_markup("<b>WARNING:</b> The version of dell-recovery installed \
was intended for a different release of Ubuntu.  \nYou may run into problems.\n\
Visit http://launchpad.net/ubuntu/+source/dell-recovery to fetch the correct version.")
        self.plugin_widgets = label
