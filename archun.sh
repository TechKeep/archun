#!/bin/bash
# archun by github.com/TechKeep

startCustomInstProcess() {
	echo "You have selected the AUTOMATIC process."
	echo "!! WARNING !! - EVERYTHING will be ERASED on this device."
	read -p "If you want to proceed, press ENTER. If not, type CTRL+C."
	read -p "Last warning. Are you sure? Press ENTER to proceed."

}


mainMenu() {
  echo "- - ArchUn: Part 1 - -"
  echo "ArchUn is an automatic ArchLinux install script."
  echo "You can either start the script with default settings, or use some custom values."
  echo "!! WARNING !! - This will ERASE EVERYTHING on the device you're using it from."
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