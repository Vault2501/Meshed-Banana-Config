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


configure_wifi() {
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
        fi
    done
}

DEVICE=$(image_mount)
configure_wifi $DEVICE
image_umount $DEVICE
