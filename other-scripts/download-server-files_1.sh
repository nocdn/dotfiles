#!/bin/bash

# Set SFTP credentials and the target directory
SFTP_SERVER="de11.pebblehost.com"
SFTP_PORT="2222"
SFTP_USERNAME="bartek.bak@protonmail.com.42bf55b3"
SFTP_PASSWORD="Our_Server"
REMOTE_DIR="world/"
LOCAL_DIR="."

# Create a dated directory name
DATE=$(date +"%d-%m-%Y-%H-%M")
DATED_LOCAL_DIR="server-backup-$DATE"

# Create the dated directory
mkdir -p "$DATED_LOCAL_DIR"

# Use lftp to download the entire directory
lftp -u $SFTP_USERNAME,$SFTP_PASSWORD sftp://$SFTP_SERVER:$SFTP_PORT -e "mirror $REMOTE_DIR $DATED_LOCAL_DIR; quit"

# Zip the dated directory
zip -r "$DATED_LOCAL_DIR.zip" "$DATED_LOCAL_DIR"

sleep 2

echo "removing $DATED_LOCAL_DIR"

# Remove the unzipped dated directory
rm -rf "$DATED_LOCAL_DIR"
