#!/bin/sh

#Remove the ricoh_mmc driver if it's loaded.
#It can cause major problems in MDIAGS since the
#PCI address space has changed if it is still loaded
#when rebooting.

if lsmod | grep ricoh_mmc >/dev/null; then
	rmmod ricoh_mmc
fi
