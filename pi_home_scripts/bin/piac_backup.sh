#!/bin/bash

# This script name
SC=`basename $0`

TMP_DIR="/tmp/"
DATE=$(date +"%d-%m-%Y_%H%M")
BKP_FILE="$TMP_DIR/piac_backup_$DATE.tar"
BKP_DIRS="/home/pi/bin /etc /var/spool/cron"
DROPBOX_UPLOADER=/home/pi/GIT/Dropbox-Uploader/dropbox_uploader.sh

echo "[$(date '+%x %X')] [$SC] Creating backup."
tar cf "$BKP_FILE" $BKP_DIRS > /dev/null

echo "[$(date '+%x %X')] [$SC] Compressing backup."
gzip "$BKP_FILE"

echo "[$(date '+%x %X')] [$SC] Starting to upload..."
$DROPBOX_UPLOADER -f /home/pi/.dropbox_uploader upload "$BKP_FILE.gz" / > /dev/null

# Check result
if (( $? )); then
	echo "[$(date '+%x %X')] [$SC] Error uploading backup file."
else

	echo "[$(date '+%x %X')] [$SC] Success. Cleaning up and closing."
	rm -fr "$BKP_FILE.gz"
fi


