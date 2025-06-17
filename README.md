# RATCOON Forensic Toolkit

This repository contains utilities for the RATCOON toolkit.

## Face Recognition Module

The `face_recon.sh` script scans a folder of images, detects faces, and extracts EXIF metadata.

Usage:

```bash
./face_recon.sh
```

You will be prompted to choose a directory containing images (JPG or PNG). If faces are detected, matching images are copied into a report folder under `./reports/` and metadata is written to `face_metadata.csv`.

## Photo Recon GUI

The `ratcoon_photorecon_gui.sh` script provides a graphical workflow for scanning images, storing results in timestamped case folders and logging metadata about faces and GPS information.

Usage:

```bash
./ratcoon_photorecon_gui.sh
```

The script displays progress and saves output in `./reports/case_TIMESTAMP/`.
