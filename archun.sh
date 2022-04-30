#!/bin/bash
# ArchUn by github.com/TechKeep

######################################
######################################
######################################
#### User-defined variables START ####
######################################

# Time zone and locale
TIMEZONESTRING="America/Toronto" # Time zone
LOCALEGEN="en_CA.UTF-8 UTF-8" # Locale
LOCALELANG="LANG=en_CA.UTF-8" # Locale

# Hostname of the machine
THEHOSTNAME="arch"

# Disk (find out with "fdisk -l")
# MAKE SURE TO ALSO PAY ATTENTION TO THE VALUES BELOW.
# PLEASE MAKE SURE YOU UNDERSTAND.
DEFAULTDISK="/dev/sda"

# Partition variables to append to the DEFAULTDISK variable.
# This is important, because if you use an NVMe drive and the
# variable in DEFAULTDISK is, for example, "/dev/nvme0n1", you
# will need to use "p1", "p2" and "p3" as partition numbers.
# If your drive is still named similarly to "/dev/sda", then
# you will need to use "1", "2" and "3" as partition numbers.
BOOTPARTNUM="1"
SWAPPARTNUM="2"
ROOTPARTNUM="3"

# Boot partition size in MiB. Number only.
BOOTPART="300"

# Swap partition size in MiB. Number only.
SWAPPART="4000"

# Root partition size in %. Percentage.
# NOTICE: You can also use MiB for this one.
# !!!HOWEVER!!!, you must specify the symbol manually ("%" or "MiB")
# in the separate variable named "ROOTPARTENDUNIT" below.
ROOTPART="100" # WARNING, READ ABOVE
ROOTPARTSIZETYPE="%" # WARNING, READ ABOVE

# Root password
# If AUTOMATICROOTACCOUNT is set to "yes", it will use
# the value inside ROOTACCOUNTPASSWORD. If it's set to
# "no", it will ignore it and ask you at the end.
AUTOMATICROOTACCOUNT="no"
ROOTACCOUNTPASSWORD="password"

# Skip asking for extras?
# If this is set to "yes", ArchLinux will only install
# in commandline mode. Keep it set to "no" if you want
# to be asked to install a Desktop Environment.
SKIPEXTRAS="no"

######################################
####  User-defined variables END  ####
######################################
######################################
######################################

# Do not edit this unless you really know what you're doing.
# If you don't do EVERYTHING necessary, a lot of storage space
# will end up wasted inbetween partitions. Everything is in MiB.
PARTSIZETYPE="MiB"

# Partition size calculation, relying on MiB.
BOOTPARTSTART="$((16))"
BOOTPARTEND="$(($BOOTPARTSTART+$BOOTPART))"
SWAPPARTSTART="$(($BOOTPARTEND+1))"
SWAPPARTEND="$(($SWAPPARTSTART+$SWAPPART))"
ROOTPARTSTART="$(($SWAPPARTEND+1))"
ROOTPARTEND="$ROOTPART"

startAutomaticInstProcess() {
	# Part 2
	curl https://raw.githubusercontent.com/TechKeep/archun/test/archun2.sh -o archun2.sh
	# Extras
	curl https://raw.githubusercontent.com/TechKeep/archun/test/archunextras.sh -o archunextras.sh
	sed -i "3 i TIMEZONESTRING='$TIMEZONESTRING'" archun2.sh
	sed -i "4 i LOCALEGEN='$LOCALEGEN'" archun2.sh
	sed -i "5 i LOCALELANG='$LOCALELANG'" archun2.sh
	sed -i "6 i THEHOSTNAME='$THEHOSTNAME'" archun2.sh
	sed -i "7 i DEFAULTDISK='$DEFAULTDISK'" archun2.sh
	sed -i "8 i AUTOMATICROOTACCOUNT='$AUTOMATICROOTACCOUNT'" archun2.sh
	sed -i "9 i ROOTACCOUNTPASSWORD='$ROOTACCOUNTPASSWORD'" archun2.sh
	sed -i "10 i SKIPEXTRAS='$SKIPEXTRAS'" archun2.sh
	clear
	echo "You have started the AUTOMATIC process."
	echo "!! WARNING !! - EVERYTHING will be ERASED from this device."
	read -p "If you want to proceed, press ENTER. If not, type CTRL+C."
	read -p "Last warning. Are you sure? Press ENTER to proceed."
	clear
	# Setting date and time
	timedatectl set-ntp true
	# Creating the partitions with provided options
	sudo parted $DEFAULTDISK --script mklabel gpt # GPT for UEFI
	sudo parted $DEFAULTDISK --script mkpart primary fat32 $BOOTPARTSTART$PARTSIZETYPE $BOOTPARTEND$PARTSIZETYPE
	sudo parted $DEFAULTDISK --script mkpart primary linux-swap $SWAPPARTSTART$PARTSIZETYPE $SWAPPARTEND$PARTSIZETYPE
	sudo parted $DEFAULTDISK --script mkpart primary ext4 $ROOTPARTSTART$PARTSIZETYPE $ROOTPARTEND$ROOTPARTSIZETYPE
	mkfs.ext4 $DEFAULTDISK$ROOTPARTNUM
	mkswap $DEFAULTDISK$SWAPPARTNUM
	mkfs.fat -F 32 $DEFAULTDISK$BOOTPARTNUM
	# Mounting all drives
	mount $DEFAULTDISK$ROOTPARTNUM /mnt
	mount --mkdir $DEFAULTDISK$BOOTPARTNUM /mnt/boot
	swapon $DEFAULTDISK$SWAPPARTNUM
	# Install base with pacstrap
	pacstrap /mnt base linux linux-firmware
	# Generate Fstab
	genfstab -U /mnt >> /mnt/etc/fstap
	# Use part 2 in chroot
	#echo "Time to chroot"
	#arch-chroot /mnt /bin/bash -e -x /archun2.sh
	cp archun2.sh /mnt/archun2.sh
	cp archunextras.sh /mnt/archunextras.sh
	chmod +x /mnt/archun2.sh
	chmod +x /mnt/archunextras.sh
	arch-chroot /mnt ./archun2.sh
}

mainMenu() {
	echo "- - ArchUn - -"
	echo "ArchUn is an automatic ArchLinux install script."
	echo "It is meant as a quick method of creating ArchLinux virtual machines."
	echo "You can either start the script with default settings, or use some custom values."
	# TODO: add a built-in way of editing the settings without having to edit the script.
	echo "If you want to edit the default settings, check out the related post to see how."
	echo "!! WARNING !! - Using this script will ERASE EVERYTHING on the device."
	echo " "
	PS3="Choose an option's number and press ENTER to confirm: "
	options=("Proceed" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"Proceed")
				startAutomaticInstProcess
				clear
				rm /mnt/archun2.sh
				rm /mnt/archunextras.sh
				echo " "
				echo " "
				echo " "
				echo "The installation should now be complete. If something"
				echo "didn't work properly, you can still do 'arch-chroot /mnt'"
				echo "right now to fix it manually."
				echo "If everything seemed fine, you can eject the"
				echo "installation media and reboot the machine."
				echo " "
				echo " "
				exit
				;;
			"Quit")
				exit
				;;
			*) echo "Invalid option. $REPLY";;
		esac
	done
}

clear
mainMenu