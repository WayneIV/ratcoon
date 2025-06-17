# RATCOON Forensic Toolkit

This repository contains utilities for the RATCOON toolkit.

## Face Recognition Module

The `face_recon.sh` script scans a folder of images, detects faces, and extracts EXIF metadata.

Usage:

```bash
./face_recon.sh
```

You will be prompted to choose a directory containing images (JPG or PNG). If faces are detected, matching images are copied into a report folder under `./reports/` and metadata is written to `face_metadata.csv`.
