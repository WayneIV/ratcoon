#!/bin/bash

# RATCOON Photo Recon GUI Script

# Check required commands
missing=()
for cmd in zenity exiftool python3; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
done

# Check python module face_recognition
if ! python3 - <<'PY'
import importlib, sys
sys.exit(0 if importlib.util.find_spec('face_recognition') else 1)
PY
then
    missing+=("face_recognition (python module)")
fi

if [ ${#missing[@]} -ne 0 ]; then
    zenity --error --text="Missing required tools: ${missing[*]}" 2>/dev/null
    exit 1
fi

# Select folder
folder=$(zenity --file-selection --directory --title="Select image folder" 2>/dev/null)
if [ -z "$folder" ]; then
    zenity --info --text="Operation cancelled." 2>/dev/null
    exit 0
fi

# Prepare case directories
timestamp=$(date +%Y%m%d_%H%M%S)
case_dir="./reports/case_${timestamp}"
faces_dir="$case_dir/faces"
mkdir -p "$faces_dir"

csv="$case_dir/face_metadata.csv"
echo "file,face_count,datetime,gps_lat,gps_lon" > "$csv"
error_log="$case_dir/error_log.txt"

# Collect images
mapfile -d '' images < <(find "$folder" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \) -print0)
count=${#images[@]}

if [ "$count" -eq 0 ]; then
    zenity --info --text="No images found in selected folder." 2>/dev/null
    exit 0
fi

found_file=$(mktemp)
# flag file will indicate at least one face was found

# Process with progress bar
(
    i=0
    for img in "${images[@]}"; do
        ((i++))
        percent=$(( i*100/count ))
        echo $percent
        echo "# Processing $(basename "$img")"

        face_count=$(IMG_PATH="$img" python3 - <<'PY'
import os, face_recognition, sys
try:
    img_path = os.environ['IMG_PATH']
    image = face_recognition.load_image_file(img_path)
    faces = face_recognition.face_locations(image)
    print(len(faces))
except Exception as e:
    print("ERR:"+str(e))
PY
)
        if [[ $face_count == ERR:* ]]; then
            echo "${face_count#ERR:}" >> "$error_log"
            face_count=0
        fi

        datetime=$(exiftool -s3 -DateTimeOriginal "$img" 2>>"$error_log")
        gpslat=$(exiftool -s3 -GPSLatitude "$img" 2>>"$error_log")
        gpslon=$(exiftool -s3 -GPSLongitude "$img" 2>>"$error_log")

        if [ "$face_count" -gt 0 ]; then
            cp "$img" "$faces_dir/"
            echo 1 > "$found_file"
        fi

        echo "\"$img\",$face_count,\"$datetime\",\"$gpslat\",\"$gpslon\"" >> "$csv"
    done
    echo 100
    echo "# Done"
) | zenity --progress --title="RATCOON Photo Recon" --percentage=0 --auto-close 2>/dev/null
found_faces=0
if [ -s "$found_file" ]; then
    found_faces=1
fi
rm -f "$found_file"

if [ "$found_faces" -eq 0 ]; then
    zenity --info --text="Photo Recon Complete. No faces found. Results saved to $case_dir" 2>/dev/null
else
    zenity --info --text="Photo Recon Complete. Results saved to $case_dir" 2>/dev/null
fi
