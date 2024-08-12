#!/bin/bash

# Set FTP credentials and the target directory
FTP_SERVER="de11.pebblehost.com"
FTP_USERNAME="bartek.bak@protonmail.com.809868"
FTP_PASSWORD="Our_Server"
REMOTE_DIR="world/"
LOCAL_DIR="."

# Use wget to download the entire directory
wget -m --user="$FTP_USERNAME" --password="$FTP_PASSWORD" ftp://$FTP_SERVER/$REMOTE_DIR -P $LOCAL_DIR

DATE=$(date +"%d-%m-%Y-%H-%M")
DATED_LOCAL_DIR="server-backup-$DATE"

mv de11.pebblehost.com/ "$DATED_LOCAL_DIR"/

# zip -r server-backup-14-08-2024-16-12.zip server-backup-14-08-2024-16-12/

zip -r "$DATED_LOCAL_DIR".zip "$DATED_LOCAL_DIR"/

rm -rf "$DATED_LOCAL_DIR"/
