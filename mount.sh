#!/bin/bash

# Install necessary packages
sudo apt install -y nfs-common ntfs-3g

# Function to list NTFS partitions
list_partitions() {
    echo -e "\n\033[1;34mAvailable NTFS partitions:\033[0m"
    lsblk -o NAME,FSTYPE,SIZE,LABEL | awk '
    BEGIN {count=1}
    $2=="ntfs" {printf "%d- /dev/%s (%s - %s)\n", count++, $1, $4, $3}'
}

# Function to mount partition
mount_partition() {
    MOUNT_POINT="/mnt/ntfs_drive"
    sudo mkdir -p "$MOUNT_POINT"
    
    echo -e "\033[1;32mMounting $1 to $MOUNT_POINT...\033[0m"
    sudo mount -o defaults,exec,uid=$(id -u),gid=$(id -g) "$1" "$MOUNT_POINT"
    
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32mSuccessfully mounted at $MOUNT_POINT.\033[0m"
    else
        echo -e "\033[1;31mMount failed. Try mounting manually.\033[0m"
    fi
}

# Detect NTFS partitions
PARTITIONS=($(lsblk -o NAME,FSTYPE -nr | awk '$2=="ntfs" {print "/dev/"$1}'))

# Check if any NTFS partition is found
if [ ${#PARTITIONS[@]} -eq 0 ]; then
    echo -e "\033[1;31mNo NTFS partitions found. Exiting.\033[0m"
    exit 1
fi

while true; do
    list_partitions
    echo -e "\033[1;33mEnter the number of the NTFS partition you want to fix & mount (or type 'exit' to quit):\033[0m"
    read -r PARTITION_NUM
    
    if [[ "$PARTITION_NUM" == "exit" ]]; then
        echo -e "\033[1;34mExiting.\033[0m"
        exit 0
    fi
    
    # Validate user input
    if ! [[ "$PARTITION_NUM" =~ ^[0-9]+$ ]] || [ "$PARTITION_NUM" -lt 1 ] || [ "$PARTITION_NUM" -gt "${#PARTITIONS[@]}" ]; then
        echo -e "\033[1;31mInvalid selection. Try again.\033[0m"
        continue
    fi
    
    SELECTED_PARTITION="${PARTITIONS[$((PARTITION_NUM-1))]}"
    echo -e "\033[1;32mFixing partition: $SELECTED_PARTITION\033[0m"
    
    # Run ntfsfix on the selected partition
    sudo ntfsfix -b -d "$SELECTED_PARTITION"

    echo -e "\033[1;32mFixing completed. Attempting to mount...\033[0m"
    
    # Mount the fixed partition
    mount_partition "$SELECTED_PARTITION"

    echo -e "\033[1;34mDone. You may need to reboot if issues persist.\033[0m"
done
