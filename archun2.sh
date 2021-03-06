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
#SKIPEXTRAS="no"
#INSTALLDEFAULTDE="no"

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
yes | pacman -Syu grub efibootmgr dhcpcd
systemctl start dhcpcd
systemctl enable dhcpcd
dhcpcd
mkdir /boot/grub
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --force $DEFAULTDISK

installDefaultDE() {
	yes "" | pacman -Syu lxdm 
	yes "" | pacman -Syu xfce4 
	yes "" | pacman -Syu xfce4-goodies 
	yes "" | pacman -Syu pulseaudio 
	yes "" | pacman -Syu pavucontrol 
	yes "" | pacman -Syu sudo 
	yes "" | pacman -Syu firefox 
	yes "" | pacman -Syu neofetch
	systemctl enable lxdm
}

#setRootPassword() {
#	# Set a root password
#	clear
#	echo "Setting a password for root."
#	if [ $AUTOMATICROOTACCOUNT == "yes" ]; then
#		echo $ROOTACCOUNTPASSWORD | passwd --stdin root
#		return
#	else
#		passwd
#		return
#	fi
#}

# Menu that appears when it's done
finishMenu() {
	# Install a Desktop Environment
	clear
	echo " "
	echo "Do you want to install anything extra?"
	echo " "
	PS3="Choose an option's number and press ENTER to confirm: "
	options=("Yes" "No")
	select opt in "${options[@]}"
	do
		case $opt in
			"Yes")
	 			bash archunextras.sh
	 			exit
				;;
			"No")
				exit
				;;
			*) echo "Invalid option. $REPLY";;
		esac
	done
}

doWeInstallExtras() {
	if [ $SKIPEXTRAS == "no" ]; then
		passwd
		finishMenu
	else
		if [ $INSTALLDEFAULTDE == "yes" ]; then
			installDefaultDE
			passwd
			exit
		else
			passwd
			exit
		fi
	fi
}

doWeInstallExtras

exit # Go back to part 1