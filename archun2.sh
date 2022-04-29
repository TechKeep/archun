#!/bin/bash
# ArchUn (Part 2) by github.com/TechKeep





# Variables that will be received (with different
# contents; the following values are the defaults
# and are only there for reference to make it easier).
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

# Install GRUB
yes | LC_ALL=en_US.UTF-8 pacman -Syu grub efibootmgr dhcpcd
systemctl start dhcpcd
systemctl enable dhcpcd
dhcpcd
mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --force $DEFAULTDISK

read -p "holup"

installDesktopEnvironment() {
	echo "Which preset do you want?"
	echo " "
	echo "XFCE (with LXDM) - Installs the following packages:"
	echo "lxdm xfce4 xfce4-goodies pulseaudio pavucontrol sudo firefox neofetch"
	echo " "
	PS3="Choose an option's number and press ENTER to confirm: "
	options=("XFCE" "Cancel")
	select opt in "${options[@]}"
	do
	  case $opt in
	      "XFCE")
	 		  yes | LC_ALL=en_US.UTF-8 pacman -Syu lxdm xfce4 xfce4-goodies pulseaudio pavucontrol sudo firefox neofetch
	 		  systemctl enable lxdm
	          exit
	          ;;
	      "Cancel")
	          exit
	          ;;
	      *) echo "Invalid option. $REPLY";;
	  esac
	done
}

finishedMenu() {
	# Install a Desktop Environment
	echo "Do you want to install a Desktop Environment with a preset?"
	PS3="Choose an option's number and press ENTER to confirm: "
	options=("Yes" "No")
	select opt in "${options[@]}"
	do
	  case $opt in
	      "Yes")
	 		  installDesktopEnvironment
	          exit
	          ;;
	      "No")
	          exit
	          ;;
	      *) echo "Invalid option. $REPLY";;
	  esac
	done
}

finishedMenu
read -p "holdup again"

# Set a root password
echo " "
echo " "
echo " "
echo "Setting a password for root."
passwd