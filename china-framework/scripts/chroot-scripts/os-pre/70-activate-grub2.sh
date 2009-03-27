#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

#to prevent postinst scripts complaining
#in noninteractive mode, take out grub1
#first
rm /boot/grub -rf
apt-get install -y grub-pc

#Reinstall grub2 to set the default bootloader to 
#be grub2 rather than chainloading
grub-install '(hd0,3)'

#don't generate grub.cfg now.  it will be generated
#after the artwork is installed
touch /boot/grub/grub.cfg

rm -f /etc/kernel/prerm.d/last-good-boot

