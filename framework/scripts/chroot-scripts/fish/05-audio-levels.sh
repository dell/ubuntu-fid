#!/bin/sh
#
#       <05-audio.sh>
#
#       Sets the default audio volume higher since recent systems have
#       are not audible at Ubuntu defaults
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

amixer -c 0 -q set Front 100% unmute 2>&1 || true
amixer -c 0 -q set PCM 100% unmute 2>&1 || true
amixer -c 0 -q set Master 80% unmute 2>&1 || true
alsactl store 0 2>&1
