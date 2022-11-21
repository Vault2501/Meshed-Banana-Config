#!/bin/sh

IMAGE=$1
SSID=$2
KEY=$3
COUNTRY=${4:-"DE"}

BASEPATH="/tmp"

image_mount() {
    device=$(losetup --show -f -P $IMAGE)
    for partition in "$device"?*; do
        if [ "$partition" = "${device}p*" ]; then
            partition="${device}"
        fi
        dst="$BASE/$(basename "$partition")"
        mkdir -p "$dst"
        mount "$partition" "$dst"
    done
    sleep 1
    echo $device
}


image_umount() (
  device=$DEVICE
  for partition in $(ls ${device}p*); do
    sudo umount "$partition"
  done
  sudo losetup -d "$device"
)


configure_wifi_armbian() {
    device=$DEVICE
    for partition in $(ls ${device}p*); do
        template="$BASE/$(basename "$partition")/boot/armbian_first_run.txt.template"
        echo "Checking for ${template} in ${partition}"
        if [ -f $template ]; then
            echo "Found ${template}"
            target=$(echo $template|sed 's/armbian_first_run.txt.template/armbian_first_run.txt/')
	    cp ${template} ${target}
            echo "Patching"
	    sed -i "s/MySSID/$SSID/" $target
	    sed -i "s/MyWiFiKEY/$KEY/" $target
	    sed -i "s/GB/$COUNTRY/" $target
	    sed -i "s/FR_net_wifi_enabled=0/FR_net_wifi_enabled=1/" $target
        fi
    done
}

configure_wifi() {
    device=$DEVICE
    template="wpa_supplicant.conf.template"
    for partition in $(ls ${device}p*); do
        wpa_supplicant="$BASE/$(basename "$partition")/etc/wpa_supplicant"
	echo "Checking for ${wpa_supplicant} in ${partition}"
	if [ -d ${wpa_supplicant} ]; then
	    echo "Found ${wpa_supplicant}"
	    target="$BASE/$(basename "$partition")/etc/wpa_supplicant.conf"
	    cp ${template} ${target}
	    echo "Patching ${target}"
	    sed -i "s/MySSID/$SSID/" $target
            sed -i "s/MyWiFiKEY/$KEY/" $target
            sed -i "s/GB/$COUNTRY/" $target
	fi
    done
}


DEVICE=$(image_mount)
configure_wifi $DEVICE
read
image_umount $DEVICE
