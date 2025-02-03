# ubuntu-disk-mounter

``` bash
#!/bin/bash

# List all available NTFS partitions with names
list_partitions() {
    echo "Available NTFS partitions:"
    lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL | awk '$2=="ntfs" {print NR"- "/"dev/"$1, "("$5" - "$3")"}'
}

# Detect NTFS partitions
PARTITIONS=($(lsblk -o NAME,FSTYPE -nr | awk '$2=="ntfs" {print "/dev/"$1}'))

if [ ${#PARTITIONS[@]} -eq 0 ]; then
    echo "No NTFS partitions found. Exiting."
    exit 1
fi

list_partitions

# Prompt user to select a partition
echo "Enter the number of the NTFS partition you want to fix/mount:"
read PARTITION_NUM

if [[ ! $PARTITION_NUM =~ ^[0-9]+$ ]] || [ $PARTITION_NUM -lt 1 ] || [ $PARTITION_NUM -gt ${#PARTITIONS[@]} ]; then
    echo "Invalid selection. Exiting."
    exit 1
fi

SELECTED_PARTITION=${PARTITIONS[$((PARTITION_NUM-1))]}
echo "Selected partition: $SELECTED_PARTITION"

# Get partition label
PARTITION_LABEL=$(lsblk -o NAME,LABEL | grep $(basename $SELECTED_PARTITION) | awk '{print $2}')
MOUNT_POINT="/mnt/${PARTITION_LABEL:-$(basename $SELECTED_PARTITION)}"

# Ensure mount point exists
sudo mkdir -p "$MOUNT_POINT"

# Check if already mounted and unmount if necessary
if mount | grep -q "$SELECTED_PARTITION"; then
    echo "$SELECTED_PARTITION is already mounted at $MOUNT_POINT. Unmounting..."
    sudo umount -l "$SELECTED_PARTITION"
else
    echo "$SELECTED_PARTITION is not mounted."
fi

# Find and kill processes using the partition
echo "Finding processes using $SELECTED_PARTITION..."
PROCESS_IDS=$(sudo lsof | grep "$SELECTED_PARTITION" | awk '{print $2}' | sort -u)
if [ -n "$PROCESS_IDS" ]; then
    echo "Killing processes: $PROCESS_IDS"
    sudo kill -9 $PROCESS_IDS
else
    echo "No processes found using $SELECTED_PARTITION."
fi

# Run ntfsfix
echo "Running ntfsfix on $SELECTED_PARTITION..."
sudo ntfsfix "$SELECTED_PARTITION"

# Remount the partition
echo "Mounting $SELECTED_PARTITION with read/write permissions at $MOUNT_POINT..."
sudo mount -t ntfs-3g -o remove_hiberfile,rw,uid=$(id -u),gid=$(id -g) "$SELECTED_PARTITION" "$MOUNT_POINT"

if mount | grep -q "$SELECTED_PARTITION"; then
    echo "$SELECTED_PARTITION successfully mounted at $MOUNT_POINT."
    cd $MOUNT_POINT
else
    echo "Failed to mount $SELECTED_PARTITION. Check dmesg logs:"
    sudo dmesg | tail -30
fi

```
