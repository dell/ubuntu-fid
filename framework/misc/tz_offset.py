#!/usr/bin/python

# This Script will run only once on
# the first boot.

# This script will update Local Time To UTC(GMT)
# The offsets in the dictionary below were lifted
# from the file tztable.xpe used by our sister group.

#DST is ignored since a large number of locales don't
#use it.  See
# http://en.wikipedia.org/wiki/Daylight_saving_time_around_the_world
# for more information

import os
from datetime import datetime, timedelta

Dict = {'amf':-5, 'apcc':+8, 'bcc':+3, 'ccc':+9, 'emf':+0, 'icc':+5, 'tcc':-6}

# The #VALUE# is substituted at image download time
# Dont edit the following line
MFGSITE = '#VALUE#'

# Pick a MFGSITE OR set default value
FACTORY_OFFSET = Dict['amf']
if MFGSITE.lower() in Dict:
        FACTORY_OFFSET = Dict[MFGSITE.lower()]

offset = timedelta(hours=FACTORY_OFFSET)
current_date = datetime.today()
new_date = current_date - offset

os.system('date --set="' + new_date.strftime('%d %b %Y %H:%M') + '"')
os.system('hwclock --systohc')
os.remove('/etc/init.d/tz_offset.py')
os.remove('/etc/rc2.d/S02_force_utc')
