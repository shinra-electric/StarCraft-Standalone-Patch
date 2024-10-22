#!/usr/bin/env zsh

SCRIPT_DIR=${0:a:h}
cd "$SCRIPT_DIR"

# ANSI colour codes
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

introduction() {
	echo "\n${PURPLE}This script will patch StarCraft to launch without the need for Battle.net or the StarCraft Launcher app${NC}"
	echo "${RED}This will disable online play.${NC}"
	echo "\n${PURPLE}A new icon that fits macOS is optional.${NC}"
	echo "${PURPLE}It may take some time (or a reboot) for Finder to recognise the new icon.${NC}\n"
	
	echo "${PURPLE}- Download the latest version of StarCraft using Battle.net${NC}"
	echo "${PURPLE}- Copy the script to the StarCraft/x86_64 folder and run it from there${NC}"
	
	echo "\n${PURPLE}After running the script, place the patched app in the same folder as the following data folders:${NC}"
	echo "${GREEN}Data${NC}"
	echo "${GREEN}locales${NC}"
	echo "${GREEN}Maps${NC}"
}

main_menu() {
	PS3='Would you like to continue? '
	OPTIONS=(
		"Patch Only"
		"Patch and New Icon"
		"Quit")
	select opt in $OPTIONS[@]
	do
		case $opt in
			"Patch Only")
				check_data
				set_variables
				create_launch_script
				set_launch_script
				sign
				echo "${PURPLE}Script completed.${NC}"
				exit 0
				;;
			"Patch and New Icon")
				check_data
				set_variables
				create_launch_script
				set_launch_script
				get_icon
				sign
				echo "${PURPLE}Script completed.${NC}"
				exit 0
				;;
			"Quit")
				echo -e "${PURPLE}Quitting${NC}"
				exit 0
				;;
			*) 
				echo "\"$REPLY\" is not one of the options..."
				echo "Enter the number of the option and press enter to select"
				;;
		esac
	done
}

check_data() {
	if [[ ! -a "StarCraft.app" ]]; then 
	echo "${RED}Couldn't find a StarCraft app bundle.${NC}"
	echo "${PURPLE}Please run the script from the same folder as the app.${NC}"
	exit 0
	fi
}

set_variables() {
	echo "${PURPLE}Setting variables...${NC}"
	GAME_ID="StarCraft"
	ICON_URL='https://parsefiles.back4app.com/JPaQcFfEEQ1ePBxbf6wvzkPMEqKYHhPYv8boI1Rc/19a774b8baa4ad3dd3e9e097d30d6cd9_Starcraft.icns'
}

# Create launch script and set executable permissions
create_launch_script() {
	echo "${PURPLE}Creating launcher script...${NC}"
	LAUNCHER="#!/usr/bin/env zsh
	
	SCRIPT_DIR=\${0:a:h}
	cd "\$SCRIPT_DIR"
	
	./${GAME_ID} -launch -uid s 1"
	echo "${LAUNCHER}" > "${GAME_ID}.app/Contents/MacOS/launch_${GAME_ID}.sh"
	chmod +x "${GAME_ID}.app/Contents/MacOS/launch_${GAME_ID}.sh"
}

# Change CFBundleExecutable to be the script
set_launch_script() {
	echo "${PURPLE}Changing bundle executable...${NC}"
	sed -i '' '14 s/StarCraft/launch_starcraft.sh/' ${GAME_ID}.app/Contents/Info.plist
	echo "${PURPLE}Changing bundle identifier...${NC}"
	sed -i '' '18 s/com.blizzard.Starcraft/com.blizzard.Starcraft.offline/' ${GAME_ID}.app/Contents/Info.plist
}

# Replace Icon
get_icon() {
	echo "${PURPLE}Replacing icon${NC}"
	curl -o ${GAME_ID}.app/Contents/Resources/${GAME_ID}.icns $ICON_URL
}

sign() {
	echo "${PURPLE}Signing...${NC}"
	codesign --force --deep --sign - ${GAME_ID}.app/Contents/MacOS/${GAME_ID}
}

introduction
main_menu