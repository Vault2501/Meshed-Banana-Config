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
    sed -i.bak "/^  \[\[RNode LoRa Interface/,/^  \[\[/{s/^.*$entry =.*/    port = $evalue/}" $CONFIG 
}

# read all values from file and fill up array
for value in $VALUES; do
	ARR_CONF[$value]=$(get_value $value)
done

# create dialog menu
count=0
menu=""
for k in "${!ARR_CONF[@]}"; do
    count=$(($count + 1))
    menu="$menu $k ${ARR_CONF[$k]}"
done

dialog --clear --title "Menu Title" --menu "menu" $((${#ARR_CONF[@]}+7)) 60 ${#ARR_CONF[@]} $menu 

