#!/bin/bash
# ArchUn by github.com/TechKeep

######################################
#### User-defined variables START ####
######################################

TIMEZONESTRING="America/Toronto" # Time zone
LOCALEGEN="en_CA.UTF-8 UTF-8" # Locale
LOCALELANG="LANG=en_CA.UTF-8" # Locale
THEHOSTNAME="arch" # Hostname
DEFAULTDISK="/dev/sda" # Disk (find out with "fdisk -l")

# Boot partition size. # Total size: 300MiB
BOOTPARTSTART="16MiB" # Starts at position 16MiB
BOOTPARTEND="316MiB" # Ends at position 316MiB

# Swap partition size. # Total size: 4096MiB
SWAPPARTSTART="317MiB" # Starts at position 317MiB
SWAPPARTEND="4413MiB" # Ends at position 4413MiB

# Root partition size. # Total size: rest of disk
ROOTPARTSTART="4414MiB" # Starts at position 4414MiB
ROOTPARTEND="100%" # Ends at the end of the disk

######################################
####  User-defined variables END  ####
######################################

# I'll calculate sizes automatically
# once I'm done and everything works

# Naming each variable for which is which to make it easier
BOOTPARTNUM="1"
SWAPPARTNUM="2"
ROOTPARTNUM="3"

startAutomaticInstProcess() {
	curl https://techkeep.net/archun/archun2.sh -o archun2.sh
	sed -i "3 i TIMEZONESTRING='$TIMEZONESTRING'" archun2.sh
	sed -i "4 i LOCALEGEN='$LOCALEGEN'" archun2.sh
	sed -i "5 i LOCALELANG='$LOCALELANG'" archun2.sh
	sed -i "6 i THEHOSTNAME='$THEHOSTNAME'" archun2.sh
	sed -i "7 i DEFAULTDISK='$DEFAULTDISK'" archun2.sh
	clear
	echo "You have selected the AUTOMATIC process."
	echo "!! WARNING !! - EVERYTHING will be ERASED from this device."
	read -p "If you want to proceed, press ENTER. If not, type CTRL+C."
	read -p "Last warning. Are you sure? Press ENTER to proceed."
	clear
	# Setting date and time
	timedatectl set-ntp true
	# Creating the partitions with provided options
	sudo parted $DEFAULTDISK --script mklabel gpt # GPT for UEFI
	sudo parted $DEFAULTDISK --script mkpart primary fat32 $BOOTPARTSTART $BOOTPARTEND
	sudo parted $DEFAULTDISK --script mkpart primary linux-swap $SWAPPARTSTART $SWAPPARTEND
	sudo parted $DEFAULTDISK --script mkpart primary ext4 $ROOTPARTSTART $ROOTPARTEND
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
	echo "Time to chroot"
	#arch-chroot /mnt /bin/bash -e -x /archun2.sh
	cp archun2.sh /mnt/archun2.sh
	chmod +x /mnt/archun2.sh
	clear
	arch-chroot /mnt ./archun2.sh
}

mainMenu() {
	echo "- - ArchUn - -"
	echo "ArchUn is an automatic ArchLinux install script."
	echo "You can either start the script with default settings, or use some custom values."
	echo "!! WARNING !! - Using this script will ERASE EVERYTHING on the device."
	echo "..."
	PS3='Choose a number and press ENTER to confirm: '
	options=("Proceed" "Quit")
	select opt in "${options[@]}"
	do
	  case $opt in
	      "Proceed")
	          startAutomaticInstProcess
	          clear
	          echo "..."
	          echo "The installation should now be complete. If something"
	          echo "didn't work properly, you can still do"
	          echo "'arch-chroot /mnt'"
	          echo "right now to fix it manually."
	          echo "..."
	          exit
	          ;;
	      "Quit")
	          exit
	          ;;
	      *) echo "invalid option $REPLY";;
	  esac
	done
}

clear
mainMenu