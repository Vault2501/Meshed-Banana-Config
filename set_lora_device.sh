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

for value in $VALUES; do
	ARR_CONF[$value]=$(get_value $value)
done

for k in "${!ARR_CONF[@]}"
do
  printf "%s\n" "$k=${ARR_CONF[$k]}"
done
