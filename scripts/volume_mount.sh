#!/bin/bash
yum update -y
yum install -y lvm2 xfsprogs nvme-cli

# Identify NVMe devices for MongoData and MongoLogs
MONGO_DATA_DEVICE=$(lsblk -o NAME,SIZE | grep -E "1T" | awk '{print $1}')
MONGO_LOGS_DEVICE=$(lsblk -o NAME,SIZE | grep -E "500G" | awk '{print $1}')

# Prepare MongoData volume
pvcreate /dev/$MONGO_DATA_DEVICE
vgcreate mongo_data_vg /dev/$MONGO_DATA_DEVICE
lvcreate -L 950G -n mongo_data_lv mongo_data_vg
mkfs.xfs /dev/mongo_data_vg/mongo_data_lv
mkdir -p /MongoData
mount /dev/mongo_data_vg/mongo_data_lv /MongoData
echo "/dev/mongo_data_vg/mongo_data_lv /MongoData xfs defaults 0 0" >> /etc/fstab

# Prepare MongoLogs volume
pvcreate /dev/$MONGO_LOGS_DEVICE
vgcreate mongo_logs_vg /dev/$MONGO_LOGS_DEVICE
lvcreate -L 450G -n mongo_logs_lv mongo_logs_vg
mkfs.xfs /dev/mongo_logs_vg/mongo_logs_lv
mkdir -p /MongoLogs
mount /dev/mongo_logs_vg/mongo_logs_lv /MongoLogs
echo "/dev/mongo_logs_vg/mongo_logs_lv /MongoLogs xfs defaults 0 0" >> /etc/fstab