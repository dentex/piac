#!/bin/bash

SC=`basename $0`

FRAME="/home/pi/log/webcam.jpg"
FRAME_OFF="/home/pi/log/webcam_off.jpg"
FRAME_ERROR="/home/pi/log/webcam_error.jpg"

WEBCAM_OFF="/home/pi/log/webcam_status_off"

# dropbox_uploader script
DROPBOX_UPLOADER=/home/pi/GIT/Dropbox-Uploader/dropbox_uploader.sh

# Hour of the day
H=`date +%H`

function check_network {
  ping -c 1 -w 3 8.8.8.8 > /dev/null 2>&1
  if [ "$?" -ne 0 ]; then
    #echo "[$(date '+%x %X')] [$SC] No network connection. Closing"
    exit 1
  fi
}

function get_frame {
  fswebcam -q -r 320x232 --timestamp "%H:%M:%S     " -d /dev/video0 $FRAME

  # Check result
  if (( $? )); then
	  echo "[$(date '+%x %X')] [$SC] fswebcam error."
      upload_frame $FRAME_ERROR
      exit 1
  fi
}

function upload_frame {
  #echo "[$(date '+%x %X')] [$SC] Uploading webcam frame..."
  $DROPBOX_UPLOADER -f /home/pi/.dropbox_uploader upload $1 /webcam-frame/webcam.jpg > /dev/null

  # Check result
  if (( $? )); then
	  echo "[$(date '+%x %X')] [$SC] Webcam frame uploading error."
  fi
}

## RUN ##

check_network

# upload a real image from 06:00 to 16:59
# otherwise use a placeholder
if [ "$H" -gt 5 ] && [ "$H" -lt 17 ]; then
  if [ -f "$WEBCAM_OFF" ]; then
    rm $WEBCAM_OFF
  fi
  get_frame
  upload_frame $FRAME
else
  if [ ! -f "$WEBCAM_OFF" ]; then
    upload_frame $FRAME_OFF
    touch $WEBCAM_OFF
  fi
fi
