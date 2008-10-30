#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

# Install debs from debs/grub2
if ls /cdrom/debs/grub2/*.deb > /dev/null 2>&1; then
    #to prevent postinst scripts complaining
    #in noninteractive mode, take out grub1
    #first
    rm /boot/grub -rf
    gdebi -n /cdrom/debs/grub2/*.deb

    #Reinstall grub2 to set the default bootloader to 
    #be grub2 rather than chainloading
    grub-install '(hd0,3)'

    #don't generate grub.cfg now.  it will be generated
    #after the artwork is installed
    touch /boot/grub/grub.cfg
fi

