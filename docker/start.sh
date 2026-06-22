#!/bin/bash

set -euo pipefail

# Check VIDEO_URL
if [ -z "${VIDEO_URL:-}" ]; then
    echo "ERROR: VIDEO_URL is not set."
    exit 1
fi

# Check YouTube Stream Key
if [ -z "${YOUTUBE_STREAM_KEY:-}" ]; then
    echo "ERROR: YOUTUBE_STREAM_KEY is not set."
    exit 1
fi

echo "========================================"
echo "Starting YouTube Live Stream..."
echo "Video URL: $VIDEO_URL"
echo "========================================"

exec ffmpeg \
    -re \
    -stream_loop -1 \
    -i "$VIDEO_URL" \
    -c:v libx264 \
    -preset ultrafast \
    -pix_fmt yuv420p \
    -c:a aac \
    -b:a 128k \
    -ar 44100 \
    -f flv \
    "rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_STREAM_KEY}"
