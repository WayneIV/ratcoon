# RATCOON Forensic Toolkit

This repository contains utilities for the RATCOON toolkit.

## Face Recognition Module

The `face_recon.sh` script scans a folder of images, detects faces, and extracts EXIF metadata.

Usage:

```bash
./face_recon.sh
```

You will be prompted to choose a directory containing images (JPG or PNG). If faces are detected, matching images are copied into a report folder under `./reports/` and metadata is written to `face_metadata.csv`.

## Mapping Detected Locations

After running `face_recon.sh`, generate an interactive Google Map showing any GPS coordinates found in the report CSV:

```bash
python3 map_faces.py reports/case_<timestamp>/face_metadata.csv --api-key YOUR_GOOGLE_API_KEY
```

This writes a `map.html` file to the same case folder. Open it in your browser to view the locations.
