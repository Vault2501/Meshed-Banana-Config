#!/bin/sh

#CONFIG="~/.reticulum/config"
CONFIG="config"
VALUES="port frequency bandwidth txpower spreadingfactor codingrate flow_control"
declare -A ARR_CONF

get_value(){
    entry="$1"
    sed -n "/^  \[\[RNode LoRa Interface/,/^  \[\[/{s/^.*$entry = \(.*\)/\1/p}" $CONFIG
}

change_value(){
    entry="$1"
    value="$2"

    # escape value for use in sed
    evalue=$(echo $value | sed 's;/;\\/;g')

    # replace entry for value in file
    sed -i.bak "/^  \[\[RNode LoRa Interface/,/^  \[\[/{s/^.*$entry =.*/    $entry = $evalue/}" $CONFIG 
}

# read all values from file and fill up array
read_all_values() {
    for value in $VALUES; do
        ARR_CONF[$value]=$(get_value $value)
    done
}

# create dialog menu
create_menu() {
    menu=""
    for k in "${!ARR_CONF[@]}"; do
        menu="$menu $k ${ARR_CONF[$k]}"
    done
}

while true; do
    read_all_values
    create_menu
    selection=$(dialog --clear --title "Menu Title" --menu "menu" $((${#ARR_CONF[@]}+7)) 60 ${#ARR_CONF[@]} $menu 3>&1 1>&2 2>&3)
    exitstatus=$?
    
    if [ $exitstatus = 0 ]; then
        value=$(dialog --title "Change value" --inputbox "$selection" 10 60 ${ARR_CONF[$selection]} 3>&1 1>&2 2>&3)
	exitstatus=$?

	if [ $exitstatus = 0 ]; then
            change_value $selection $value
	fi
    else
        exit 0
    fi
done
