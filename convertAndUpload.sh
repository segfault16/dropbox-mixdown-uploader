#!/bin/bash
# Set environment DROPBOX_API_TOKEN

DROPBOX_ROOT="/BA Audiolabs Audio/Collaboration Mixdowns"

for file in Mixdown/*/*.wav 
do
    cleanedFile=$(echo "$file" | sed 's/^Mixdown\/*//' | sed 's/\//_/')
    cleanedMp3="${cleanedFile%.wav}.mp3"
    echo "Processing: $file -> $cleanedMp3"
    
    # Check file exists in Dropbox
    curl -s -X POST https://api.dropboxapi.com/2/files/get_metadata \
        --header "Authorization: Bearer $DROPBOX_API_TOKEN" \
        --header "Content-Type: application/json"     \
        --data "{\"path\": \"$DROPBOX_ROOT/$cleanedMp3\",\"include_media_info\": false,\"include_deleted\": true,\"include_has_explicit_shared_members\": false}" | jq 'if has("error") then  error("not found") else . end'
    if [ $? -eq 0 ]; then
        echo "Skipping: $file -> Already exists or existed"
    else
        echo "Converting to mp3"
        ffmpeg -y -i "$file" -ab 320k "$cleanedMp3"
        echo "Uploading to $DROPBOX_ROOT/$cleanedMp3"
        curl -X POST https://content.dropboxapi.com/2/files/upload \
            --header "Authorization: Bearer $DROPBOX_API_TOKEN" \
            --header 'Content-Type: application/octet-stream' \
            --header "Dropbox-API-Arg: {\"path\":\"$DROPBOX_ROOT/$cleanedMp3\"}" \
            --data-binary @"$cleanedMp3"
    fi
done