#!/bin/bash

# Install necessary packages
sudo apt install -y nfs-common ntfs-3g

# Function to list NTFS partitions
list_partitions() {
    echo "Available NTFS partitions:"
    lsblk -o NAME,FSTYPE,SIZE,LABEL | awk '
    BEGIN {count=1}
    $2=="ntfs" {printf "%d- /dev/%s (%s - %s)\n", count++, $1, $4, $3}'
}

# Detect NTFS partitions
PARTITIONS=($(lsblk -o NAME,FSTYPE -nr | awk '$2=="ntfs" {print "/dev/"$1}'))

# Check if any NTFS partition is found
if [ ${#PARTITIONS[@]} -eq 0 ]; then
    echo "No NTFS partitions found. Exiting."
    exit 1
fi

while true; do
    list_partitions
    echo "Enter the number of the NTFS partition you want to fix (or type 'exit' to quit):"
    read -r PARTITION_NUM
    
    if [[ "$PARTITION_NUM" == "exit" ]]; then
        echo "Exiting."
        exit 0
    fi
    
    # Validate user input
    if ! [[ "$PARTITION_NUM" =~ ^[0-9]+$ ]] || [ "$PARTITION_NUM" -lt 1 ] || [ "$PARTITION_NUM" -gt "${#PARTITIONS[@]}" ]; then
        echo "Invalid selection. Try again."
        continue
    fi
    
    SELECTED_PARTITION="${PARTITIONS[$((PARTITION_NUM-1))]}"
    echo "Fixing partition: $SELECTED_PARTITION"
    
    # Run ntfsfix on the selected partition
    sudo ntfsfix -b -d "$SELECTED_PARTITION"

    echo "Fixing completed. You may need to reboot if issues persist."
done
