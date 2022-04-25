#!/bin/bash
# archun by github.com/TechKeep

######################################
#### These values are for testing.####
#### They will be definable later ####
#### and a lot of these comments  ####
#### will be deleted.             ####
######################################

USERBIOSTYPE="bios" # "bios" or "uefi"

# The default disk (find out with "fdisk -l")
DEFAULTDISK="/dev/sda"

# I'll calculate sizes automatically
# once I'm done and everything works
if [ "$USERBIOSTYPE" == "bios" ]; then
	createThePartitions() {
		# Swap partition size. # Total size: 4096MiB
		SWAPPARTSTART="16MiB" # Starts at position 16MiB
		SWAPPARTEND="4112MiB" # Ends at position 44112MiB

		# Root partition size. # Total size: rest of disk
		ROOTPARTSTART="4113MiB" # Starts at position 4113MiB
		ROOTPARTEND="100%" # Ends at the end of the disk

		# Create the partitions with provided options
		sudo parted $DEFAULTDISK --script mklabel mbr # MBR for BIOS
		sudo parted $DEFAULTDISK --script mkpart primary linux-swap $SWAPPARTSTART $SWAPPARTEND
		sudo parted $DEFAULTDISK --script mkpart primary ext4 $ROOTPARTSTART $ROOTPARTEND
	}
else
	createThePartitions() {
		# Boot partition size. # Total size: 300MiB
		BOOTPARTSTART="16MiB" # Starts at position 16MiB
		BOOTPARTEND="316MiB" # Ends at position 316MiB

		# Swap partition size. # Total size: 4096MiB
		SWAPPARTSTART="317MiB" # Starts at position 317MiB
		SWAPPARTEND="4413MiB" # Ends at position 4413MiB

		# Root partition size. # Total size: rest of disk
		ROOTPARTSTART="4414MiB" # Starts at position 4414MiB
		ROOTPARTEND="100%" # Ends at the end of the disk

		# Create the partitions with provided options
		sudo parted $DEFAULTDISK --script mklabel gpt # GPT for UEFI
		sudo parted $DEFAULTDISK --script mkpart primary fat32 $BOOTPARTSTART $BOOTPARTEND
		sudo parted $DEFAULTDISK --script mkpart primary linux-swap $SWAPPARTSTART $SWAPPARTEND
		sudo parted $DEFAULTDISK --script mkpart primary ext4 $ROOTPARTSTART $ROOTPARTEND
	}
fi

######################################

startAutomaticInstProcess() {
	clear
	echo "You have selected the AUTOMATIC process."
	echo "!! WARNING !! - EVERYTHING will be ERASED from this device."
	read -p "If you want to proceed, press ENTER. If not, type CTRL+C."
	read -p "Last warning. Are you sure? Press ENTER to proceed."
	# Setting date and time
	timedatectl set-ntp true
	timedatectl status # optional, output to verify it's set correctly
	# Creating the partitions
	createThePartitions

}


mainMenu() {
  echo "- - ArchUn: Part 1 - -"
  echo "ArchUn is an automatic ArchLinux install script."
  echo "You can either start the script with default settings, or use some custom values."
  echo "!! WARNING !! - Using this script will ERASE EVERYTHING on the device."
  PS3='Which process do you want? (ENTER to confirm): '
  options=("Automatic" "Custom" "Continue to Part 2" "Quit")
  select opt in "${options[@]}"
  do
      case $opt in
          "Automatic")
              startAutomaticInstProcess
              ;;
          "Custom")
              startCustomInstProcess
              ;;
          "Continue to Part 2")
              continueToPart2
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