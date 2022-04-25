#!/bin/bash
# ArchUn by github.com/TechKeep

######################################
#### User-defined variables START ####
######################################
######################################

# Time zone and locale
TIMEZONESTRING="America/Toronto" # Time zone
LOCALEGEN="en_CA.UTF-8 UTF-8" # Locale
LOCALELANG="LANG=en_CA.UTF-8" # Locale

# Hostname of the machine
THEHOSTNAME="arch"

# Disk (find out with "fdisk -l")
DEFAULTDISK="/dev/sda"

# Boot partition size in MiB. Number only.
BOOTPART="300"

# Swap partition size in MiB. Number only.
SWAPPART="4096"

# Root partition size in %. Include the %.
# NOTICE: You can also use MiB for this one.
# !!!HOWEVER!!!, it has to be formatted exactly like "1234MiB".
ROOTPART="100%"

######################################
######################################
####  User-defined variables END  ####
######################################

# Naming each variable for which is which to make it easier
BOOTPARTNUM="1"
SWAPPARTNUM="2"
ROOTPARTNUM="3"
PARTSIZETYPE="MiB"

# Partition size calculation
BOOTPARTSTART="$((16))"
BOOTPARTEND="$(($BOOTPARTSTART+$BOOTPART))"

SWAPPARTSTART="$(($BOOTPARTEND+1))"
SWAPPARTEND="$(($SWAPPARTSTART+$SWAPPART))"

ROOTPARTSTART="$(($SWAPPARTEND+1))"
ROOTPARTEND="$ROOTPART"

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
	sudo parted $DEFAULTDISK --script mkpart primary fat32 $BOOTPARTSTART$PARTSIZETYPE $BOOTPARTEND$PARTSIZETYPE
	sudo parted $DEFAULTDISK --script mkpart primary linux-swap $SWAPPARTSTART$PARTSIZETYPE $SWAPPARTEND$PARTSIZETYPE
	sudo parted $DEFAULTDISK --script mkpart primary ext4 $ROOTPARTSTART$PARTSIZETYPE $ROOTPARTEND
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
	echo "If you want to edit the default settings, exit the script and read the GitHub repo to see how."
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
	          rm /mnt/archun2.sh
	          echo "..."
	          echo "The installation should now be complete. If something"
	          echo "didn't work properly, you can still do 'arch-chroot /mnt'"
	          echo "right now to fix it manually."
	          echo "If everything seemed fine, you can eject the"
	          echo "installation media and reboot the machine."
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