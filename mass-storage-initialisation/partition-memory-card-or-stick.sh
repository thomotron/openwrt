#!/bin/bash

if [[ "$1" == "" ]]; then
  echo "usage: partition-memory-card-or-stick.sh <device>"
  echo "       e.g.: partition-memory-card-or-stick.sh /dev/sdb"
  echo "WARNING: This script proceeds without asking any questions."
  echo "         If you use it on the wron disk, you WILL DESTROY"
  echo "         EVERYTHING on it."
  exit
fi

device=$1

# Check if the device is mounted anywhere as a safety catch
mounts=`mount | grep /dev/$device | wc -l`
if [[ $mounts != 0 ]]; then
  echo "It looks like that disk is mounted somewhere. Aborting."
  exit
fi

if [ ! -e /dev/$device ]; then
  echo "No such device: /dev/$device"
  exit
fi

(
  echo d # Delete first partition
  echo 1 # (provide partition number to delete if required)
  echo d # Delete second partition
  echo 2 # (provide partition number to delete if required)
  echo d # Delete third partition
  echo 3 # (provide partition number to delete if required)
  echo d # Delete fourth partition
  echo 4 # (provide partition number to delete if required)

  # Create FAT32 partition in slice 1
  echo n # Create new partition
  echo p # It should be a primary partition
  echo 1 # in slot 1
  echo   # Accept default starting location
  echo +1G # 1GB in size
  echo t # set partition type
  echo b # FAT32

  # Create ext file system in slice 2 for scratch space
  echo n # Create new partition
  echo p # It should be a primary partition
  echo 2 # in slot 2
  echo   # Accept default starting location
  echo +1G # 1GB in size
  
  # Create ext file system in slice 2 for scratch space
  echo n # Create new partition
  echo p # It should be a primary partition
  echo 4 # in slot 4
  echo   # Accept default starting location
  echo +1G # 1GB in size
  echo t # set partition type
  echo 4 # of partition 4
  echo 82 # Linux swap
  
  # Create big ext file system in slice 3 for /serval-var
  echo n # Create new partition
  echo p # It should be a primary partition
  echo 3 # in slot 3
  echo   # Accept default starting location
  echo   # Use all remaining space

  # Write changes and exit
  echo w # Write and exit 
) | fdisk /dev/$device

# Time for kernel to resync with updated mbr
sleep 3

# Now create file systems
mkfs.vfat /dev/${device}1
mkfs.ext2 /dev/${device}2
mkfs.ext2 /dev/${device}3
