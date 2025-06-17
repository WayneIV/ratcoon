#!/usr/bin/env python3
"""Generate an interactive Google Map from face_metadata.csv."""
import argparse
import csv
import json
import os

HTML_TEMPLATE = """<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8'>
<title>Face Locations</title>
<style>
  #map {{ height: 100%; width: 100%; }}
  html, body {{ height: 100%; margin: 0; padding: 0; }}
</style>
<script src='https://maps.googleapis.com/maps/api/js?key={api_key}'></script>
<script>
var markers = {markers_json};
function initMap() {{
    var map = new google.maps.Map(document.getElementById('map'), {{
        zoom: 2,
        center: markers.length ? markers[0] : {{lat:0, lng:0}}
    }});
    markers.forEach(function(m) {{
        new google.maps.Marker({{position: m, map: map, title: m.file}});
    }});
}}
</script>
</head>
<body onload='initMap()'>
<div id='map'></div>
</body>
</html>"""

def parse_args():
    p = argparse.ArgumentParser(description="Create a Google Map from face metadata")
    p.add_argument('csv_file', help='Path to face_metadata.csv')
    p.add_argument('--api-key', help='Google Maps API key (or set GOOGLE_MAPS_API_KEY)')
    p.add_argument('--output', help='Output HTML file (default map.html in same folder)')
    return p.parse_args()


def load_coords(csv_file):
    coords = []
    with open(csv_file, newline='') as f:
        reader = csv.DictReader(f)
        for row in reader:
            lat = row.get('gps_lat')
            lon = row.get('gps_lon')
            if not lat or not lon:
                continue
            try:
                coords.append({'lat': float(lat), 'lng': float(lon), 'file': row['file']})
            except ValueError:
                continue
    return coords


def main():
    args = parse_args()
    api_key = args.api_key or os.getenv('GOOGLE_MAPS_API_KEY')
    if not api_key:
        print('Google Maps API key required via --api-key or GOOGLE_MAPS_API_KEY env var')
        return 1
    markers = load_coords(args.csv_file)
    if not markers:
        print('No coordinates found.')
        return 1
    html = HTML_TEMPLATE.format(api_key=api_key, markers_json=json.dumps(markers))
    output = args.output or os.path.join(os.path.dirname(args.csv_file), 'map.html')
    with open(output, 'w') as f:
        f.write(html)
    print(f'Wrote map to {output}')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
