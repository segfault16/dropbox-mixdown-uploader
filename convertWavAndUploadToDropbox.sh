#!/bin/bash
# Set environment DROPBOX_API_TOKEN

file=$1
DROPBOX_ROOT=$2
cleanedMp3=$3

echo "Converting $file to mp3 and uploading to $DROPBOX_ROOT/$cleanedMp3"

echo "Converting to mp3"
ffmpeg -y -i "$file" -ab 320k "$cleanedMp3"
echo "Uploading to $DROPBOX_ROOT/$cleanedMp3"
curl -X POST https://content.dropboxapi.com/2/files/upload \
            --header "Authorization: Bearer $DROPBOX_API_TOKEN" \
            --header 'Content-Type: application/octet-stream' \
            --header "Dropbox-API-Arg: {\"path\":\"$DROPBOX_ROOT/$cleanedMp3\"}" \
            --data-binary @"$cleanedMp3"