#!/bin/bash

# Features:
# 1. read raspicam and stream the video to GCS
# 2. save the video to .h264 
# 3. convert the .h264 to .mp4 when the program exit

# Note:
# Since the 4G/3G network offers limited and unstable bandwidth, so the video streaming is limited to the lowest level for monitoring.
# Max bandwidth: 180kB/sec (1440000 bits / 8000)
# Play on iPhone 11 full screen 1792 x 828px, 
# Resize video to 448 x 207 aspect ratio 2.16425

# Todo:
# Capture and save the HD video, then resize it for video streaming

NOW=$(date +"%Y%m%d-%H%M")
TMP_VIDEO=${PWD}/videos/$NOW.h264
OUT_VIDEO=${PWD}/videos/$NOW.mp4
UDP_IP=192.168.192.104 # The iPhone
UDP_PORT=5600

/usr/bin/raspivid -v -w 448 -h 207 --rotation 180 --bitrate 1440000 -fps 20 \
    --vstab --nopreview --timeout 0 --output - | \
/usr/bin/tee $TMP_VIDEO | \
/usr/bin/gst-launch-1.0 -v fdsrc ! \
    h264parse ! rtph264pay ! \
    udpsink host=$UDP_IP port=$UDP_PORT

set -e
function convert {
    MP4Box -add $TMP_VIDEO $OUT_VIDEO
    rm $TMP_VIDEO
}
trap convert EXIT
