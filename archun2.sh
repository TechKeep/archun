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

# Install GRUB
pacman -Syu grub efibootmgr
mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Choose
PS3='Which process do you want? (ENTER to confirm): '
options=("default" "i386-pc" "x86_64-efi")
select opt in "${options[@]}"
do
  case $opt in
  	  "default")
          grub-install /dev/sda
          ;;
      "i386-pc")
          grub-install --force --target=i386-pc --recheck $DEFAULTDISK
          ;;
      "x86_64-efi")
          grub-install --target=x86_64-efi --efi-directory=/boot --recheck $DEFAULTDISK
          ;;
      *) echo "invalid option $REPLY";;
  esac
done