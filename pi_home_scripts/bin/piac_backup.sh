#!/bin/bash

SC=`basename $0`
DATE=`date +%Y-%m-%d_%H%M`
BKP_FILE="/mnt/DATA/piac_backup_$DATE.tar"
BKP_DIR="/mnt/DATA/piac_backup"

# Backup folders
HOME_BIN="/home/pi/bin"
HOME_LOG="/home/pi/log"
ETC="/etc"
CRON="/var/spool/cron"
BOOT="/boot"

# No network tmp flag
NNF="/tmp/$SC.nonet"

# dropbox_uploader script
DROPBOX_UPLOADER=/home/pi/GIT/Dropbox-Uploader/dropbox_uploader.sh

# Removing the "." from the script name inside `/etc/cron.hourly`, due to run-parts be choosy about file names
H_SC=`echo $SC | cut -d . -f 1`
H_SC_PATH="/etc/cron.hourly/$H_SC"

START=$(date +%s)

function remove_cron_hourly_if_present {
  [ -f $H_SC_PATH ] && rm -f $H_SC_PATH
}

function backup_and_compress {

  echo "[$(date '+%x %X')] [$SC] Creating backup."

  # storing installed packages list
  dpkg --get-selections > $HOME_LOG/installed-packages.log

  mkdir -p $BKP_DIR/$BOOT $BKP_DIR/$HOME_BIN/ $BKP_DIR/$ETC/ $BKP_DIR/$CRON/ $BKP_DIR/$HOME_LOG

  # copying /boot/config.txt
  cp /boot/config.txt $BKP_DIR/boot/config.txt

#  rsync -aAX --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} /* "$BKP_DIR"

  echo -e "$HOME_BIN\n----------------------------------" > $BKP_DIR/CHANGES
  rsync -aAXi --delete $HOME_BIN/ $BKP_DIR/$HOME_BIN >> $BKP_DIR/CHANGES
  echo -e "\n$HOME_LOG\n----------------------------------" > $BKP_DIR/CHANGES
  rsync -aAXi --exclude="last*" --delete $HOME_LOG/ $BKP_DIR/$HOME_LOG >> $BKP_DIR/CHANGES
  echo -e "\n$ETC\n----------------------------------" >> $BKP_DIR/CHANGES
  rsync -aAXi --delete $ETC/ $BKP_DIR/$ETC >> $BKP_DIR/CHANGES
  echo -e "\n$CRON\n----------------------------------" >> $BKP_DIR/CHANGES
  rsync -aAXi --delete $CRON/ $BKP_DIR/$CRON >> $BKP_DIR/CHANGES

  tar -p -cf "$BKP_FILE" $BKP_DIR > /dev/null

  echo "[$(date '+%x %X')] [$SC] Compressing backup."
  gzip -9 -f "$BKP_FILE"
}

function check_network {
  ping -c 1 -w 3 8.8.8.8 > /dev/null 2>&1
  if [ "$?" -ne 0 ]; then
    echo "[$(date '+%x %X')] [$SC] No network connection. Aborting upload. Re-scheduling next hour [$C]"
    # Adding a no network `lock` file
    touch $NNF
    # Re-scheduling
    cp $HOME_BIN/$SC $H_SC_PATH
    chmod 755 $H_SC_PATH
    exit 1
  fi
}

function upload {
  echo "[$(date '+%x %X')] [$SC] Starting to upload..."
  $DROPBOX_UPLOADER -f /home/pi/.dropbox_uploader upload "$BKP_FILE.gz" /PiAC > /dev/null

  # Check result
  if (( $? )); then
    echo "[$(date '+%x %X')] [$SC] Error uploading backup file."
  else
    echo "[$(date '+%x %X')] [$SC] Success. Cleaning up and closing."
    rm -fr "$BKP_FILE.gz"
  fi
}

remove_cron_hourly_if_present
[ -f $NNF ] || backup_and_compress
check_network
upload
[ -f $NNF ] && rm -f $NNF

FINISH=$(date +%s)
echo "[$(date '+%x %X')] [$SC] Backup total time: $(( ($FINISH-$START) / 60 )) minutes, $(( ($FINISH-$START) % 60 )) seconds" | tee $BKP_DIR/BACKUP-DATE

exit 0
