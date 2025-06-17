#!/bin/bash

# Ratcoon Face Recognition Module

# Check dependencies
missing=()
for cmd in zenity exiftool python3; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

# Check python module face_recognition
python3 - <<'PY'
import importlib, sys
sys.exit(0 if importlib.util.find_spec('face_recognition') else 1)
PY
if [ $? -ne 0 ]; then
    missing+=("face_recognition (python module)")
fi

if [ ${#missing[@]} -ne 0 ]; then
    echo "Missing required tools: ${missing[*]}" >&2
    exit 1
fi

# Select folder with zenity
folder=$(zenity --file-selection --directory --title="Select image folder" 2>/dev/null)
if [ -z "$folder" ]; then
    echo "No folder selected. Exiting." >&2
    exit 1
fi

# Prepare report directories
timestamp=$(date +%Y%m%d_%H%M%S)
report_base="./reports/case_${timestamp}"
faces_dir="$report_base/faces"
mkdir -p "$faces_dir"
csv="$report_base/face_metadata.csv"
echo "file,face_count,datetime,gps_lat,gps_lon" > "$csv"

# Collect images
mapfile -d '' images < <(find "$folder" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0)
count=${#images[@]}

process_image() {
    local img="$1"
    face_count=$(IMG_PATH="$img" python3 - <<'PY'
import os, face_recognition
img_path = os.environ['IMG_PATH']
image = face_recognition.load_image_file(img_path)
faces = face_recognition.face_locations(image)
print(len(faces))
PY
)

    if [ "$face_count" -gt 0 ]; then
        cp "$img" "$faces_dir/"
    fi

    datetime=$(exiftool -s3 -DateTimeOriginal "$img" 2>/dev/null)
    gpslat=$(exiftool -s3 -n -GPSLatitude "$img" 2>/dev/null)
    gpslon=$(exiftool -s3 -n -GPSLongitude "$img" 2>/dev/null)
    echo "\"$img\",$face_count,\"$datetime\",\"$gpslat\",\"$gpslon\"" >> "$csv"
}

# Progress bar
(
    i=0
    for img in "${images[@]}"; do
        ((i++))
        percent=$(( i*100/count ))
        echo $percent
        echo "# Processing $(basename "$img")" 
        process_image "$img"
    done
    echo 100
    echo "# Done"
) | zenity --progress --title="Ratcoon Face Recon" --percentage=0 --auto-close 2>/dev/null

zenity --info --text="Recon complete. Check your reports folder." 2>/dev/null
