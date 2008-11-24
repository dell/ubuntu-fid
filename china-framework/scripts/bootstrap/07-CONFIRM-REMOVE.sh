#!/bin/sh

remove_fn()
{
    if grep -q REMOVE /proc/cmdline; then
    # already run one time... this must be a reinstall
        # ask the user
        set +x
        CORRECT_ANSWER="REMOVE"

        if grep -q splash /proc/cmdline; then
            /sbin/usplash_write "TIMEOUT 0"
            /sbin/usplash_write "VERBOSE on"
            /sbin/usplash_write "TEXT-URGENT ---WARNING---"
            /sbin/usplash_write "TEXT-URGENT This operation will remove Ubuntu Linux from your computer"
            /sbin/usplash_write "TEXT-URGENT ALL DATA ON YOUR HARD DRIVE WILL BE PERMANENTLY LOST."
            /sbin/usplash_write "INPUT To proceed, please type: $CORRECT_ANSWER.  "
            answer=$(cat /dev/.initramfs/usplash_outfifo)
        else
            echo -e "\n\n"
            echo -e "\n\n"
            echo -e "\n\n"
            echo -e "\n\n"
            echo -e "\n\n"
            echo -e 'WARNING!    WARNING!   WARNING!'
            echo -e ""
            echo -e "This operation will remove Ubuntu Linux from your computer"
            echo -e "ALL DATA ON YOUR HARD DRIVE WILL BE PERMANENTLY LOST."
            echo -e ""
            read -p "To proceed please type: $CORRECT_ANSWER " answer > /dev/console 2>&1 < /dev/console
        fi

        if [ "$answer" = "$CORRECT_ANSWER" ]; then
            if grep -q splash /proc/cmdline; then
                /sbin/usplash_write "CLEAR"
                /sbin/usplash_write "TEXT-URGENT Removing Ubuntu linux."
            else
                echo -e "\n\n" > /dev/console
                echo "Removing Ubuntu Linux" > /dev/console
            fi
            set -x

            cp /dev /root -R
            chroot /root/ parted -s $BOOTDEV rm 2 || :
            chroot /root/ parted -s $BOOTDEV rm 3 || :
            chroot /root/ parted -s $BOOTDEV rm 4 || :
            reboot

        fi

        if grep -q splash /proc/cmdline; then
            /sbin/usplash_write "CLEAR"
            /sbin/usplash_write "TEXT-URGENT Invalid entry."
        else
            echo "Invalid entry." > /dev/console
        fi
    fi
}

while true; do remove_fn; done


