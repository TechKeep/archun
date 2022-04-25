#!/bin/bash
# ArchUn (Part 2) by github.com/TechKeep





# Values that will be generated:
#TIMEZONESTRING="America/Toronto"
#LOCALEGEN="en_CA.UTF-8 UTF-8"
#LOCALELANG="LANG=en_CA.UTF-8"
#THEHOSTNAME="arch"
#DEFAULTDISK="/dev/sda"

# Set the time zone
ln -sf /usr/share/zoneinfo/$TIMEZONESTRING /etc/localtime
# Generating /etc/adjtime
hwclock --systohc
# Generate locales
echo $LOCALEGEN >> /etc/locale.gen
locale-gen
# Select locale
echo $LOCALELANG >> /etc/locale.conf
# Set the hostname
echo $THEHOSTNAME >> /etc/hostname
# Initramfs
mkinitcpio -P
# Set a root password
passwd
