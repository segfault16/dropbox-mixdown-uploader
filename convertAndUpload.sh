#!/bin/bash
# Set environment DROPBOX_API_TOKEN

DROPBOX_ROOT="/BA Audiolabs Audio/Collaboration Mixdowns"
COPY_TO="/mixdowns/${CI_PROJECT_NAME}/"
HISTORY="${COPY_TO}_copy_history"

for file in Mixdown/*/*.wav
do
    if cat "${HISTORY}" | grep -q "${file}"; then
        echo "Ignoring ${file}"
    else
        echo "Processing: $file -> $cleanedMp3"

        mkdir -p "$COPY_TO"
        rsync -R "$file" "$COPY_TO"
        echo "${file}" >> "${HISTORY}"

        cleanedFile=$(echo "$file" | sed 's/^Mixdown\/*//' | sed 's/\//_/')
        cleanedMp3="${cleanedFile%.wav}.mp3"

        ./convertWavAndUploadToDropbox.sh "$file" "$DROPBOX_ROOT" "$cleanedMp3"
    fi
done