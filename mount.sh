#!/bin/bash

sudo apt install nfs-common sifs-utils;

# List all available NTFS partitions with names
list_partitions() {
    echo "Available NTFS partitions:"
    lsblk -o NAME,FSTYPE,SIZE,LABEL | awk '$2=="ntfs" {print NR"- "/"dev/"$1, "("$4" - "$3")"}'
}

# Detect NTFS partitions
PARTITIONS=($(lsblk -o NAME,FSTYPE -nr | awk '$2=="ntfs" {print "/dev/"$1}'))

if [ ${#PARTITIONS[@]} -eq 0 ]; then
    echo "No NTFS partitions found. Exiting."
    exit 1
fi

while true; do
    list_partitions
    echo "Enter the number of the NTFS partition you want to fix (or type 'exit' to quit):"
    read PARTITION_NUM
    
    if [[ "$PARTITION_NUM" == "exit" ]]; then
        echo "Exiting."
        exit 0
    fi
    
    if [[ ! $PARTITION_NUM =~ ^[0-9]+$ ]] || [ $PARTITION_NUM -lt 1 ] || [ $PARTITION_NUM -gt ${#PARTITIONS[@]} ]; then
        echo "Invalid selection. Try again."
        continue
    fi
    
    SELECTED_PARTITION=${PARTITIONS[$((PARTITION_NUM-1))]}
    echo "Fixing partition: $SELECTED_PARTITION"
    sudo ntfsfix -b -d "$SELECTED_PARTITION"

done
