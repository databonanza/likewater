#!/bin/bash

##########################################------------,,,,,,,,,,,,,
# MikroTik Backup Script
# by Jonathan Morgan
# v.1 beta
#
# 1. Edit TZ, MACHINES, KEY, MT_USER, and BU_DAYS for this script to work on your network.
# 2. Upload your ssh public key to each MikroTik device for the MT_USER you choose.
# 3. Ensure that each device has ssh open on port 22.
# 4. Create a directory for each device in MACHINES in BU_DIR.
# 5. Put this script in /usr/bin and run it from a cron job.
##########################################-------------''''''''''''''

export TZ="/usr/share/zoneinfo/America/Chicago"
MACHINES=(
	DEVICE1NAME:192.168.91.1
	DEVICE2NAME:192.168.91.2
)

##########################################------------,,,,,,,,,,,,,
# User variables here, please edit to match the settings you'd like to use.
EPOCH=$(date +%s) # get a date stamp we can use. DON'T EDIT THIS ONE
KEY=/root/.ssh/id_rsa_mikrotik # defines the location to the private key matching the public keys on thes devices.
MT_USER=admin # defines the username associated with the key on the devices.
BU_DAYS=10 # defines the length of time in days to keep backups.
##########################################-------------''''''''''''''

for x in "${!MACHINES[@]}"
	do \
	CPE_NAME=$(echo ${MACHINES[$x]}| awk -F":" '{print $1}')
	CPE_IP=$(echo ${MACHINES[$x]}| awk -F":" '{print $2}')
	BU_DIR=/backups/mikrotik/${CPE_NAME}/
	BU_NAME=${CPE_NAME}_${EPOCH}
	cd ${BU_DIR}
	/usr/bin/ssh -i ${KEY} -o StrictHostKeyChecking=no ${MT_USER}@${CPE_IP} "/system backup save dont-encrypt=yes name=${BU_NAME}"
	/usr/bin/sftp -i ${KEY} "${MT_USER}@${CPE_IP}:${BU_NAME}.backup"
	/usr/bin/xz ${BU_NAME}.backup
	/usr/bin/ssh -i ${KEY} ${MT_USER}@${CPE_IP} "/file remove ${BU_NAME}.backup" 
	/usr/bin/find ${BU_DIR} -maxdepth 1 -type f -name ${CPE_NAME}\* -type f -mtime +${BU_DAYS} -delete 
done
