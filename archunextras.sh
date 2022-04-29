#!/bin/bash
# ArchUn (Extras) by github.com/TechKeep

clear

installGPUDrivers() {
	echo "..."
	exit
}

installDesktopEnvironment() {
	clear
	echo " "
	echo "Which one do you want to install?"
	echo " "
	echo "XFCE (with LXDM) - Installs the following packages:"
	echo "lxdm xfce4 xfce4-goodies pulseaudio pavucontrol sudo firefox neofetch"
	echo " "
	PS3="Choose an option's number and press ENTER to confirm: "
	options=("XFCE" "Back")
	select opt in "${options[@]}"
	do
		case $opt in
			"XFCE")
	 			yes "" | pacman -Syu lxdm 
	 			yes "" | pacman -Syu xfce4 
	 			yes "" | pacman -Syu xfce4-goodies 
	 			yes "" | pacman -Syu pulseaudio 
	 			yes "" | pacman -Syu pavucontrol 
	 			yes "" | pacman -Syu sudo 
	 			yes "" | pacman -Syu firefox 
	 			yes "" | pacman -Syu neofetch
	 			systemctl enable lxdm
	 			clear
	 			installExtras
				;;
			"Back")
				clear
				installExtras
				;;
			*) echo "Invalid option. $REPLY";;
		esac
	done
	;;
}

installExtras() {
	clear
	echo " "
	echo "What (or what else) do you want to install?"
	echo " "
	PS3="Choose an option's number and press ENTER to confirm: "
	options=("Desktop Environment" "Cancel")
	select opt in "${options[@]}"
	do
		case $opt in
			"Desktop Environment")
				installDesktopEnvironment
				;;
			"Cancel")
				exit
				;;
			*) echo "Invalid option. $REPLY";;
		esac
	done
}

installExtras