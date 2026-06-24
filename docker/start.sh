#!/bin/bash
set -euo pipefail

if [ -z "${VIDEO_URL:-}" ]; then
    echo "ERROR: VIDEO_URL is not set"
    exit 1
fi

if [ -z "${YOUTUBE_STREAM_KEY:-}" ]; then
    echo "ERROR: YOUTUBE_STREAM_KEY is not set"
    exit 1
fi

echo "========================================"
echo "Starting 24/7 YouTube Stream Engine"
echo "========================================"

echo "yt-dlp:"
yt-dlp --version

echo "ffmpeg:"
ffmpeg -version | head -1

echo "========================================"

IFS=',' read -ra URLS <<< "$VIDEO_URL"

while true; do
  for url in "${URLS[@]}"; do

    echo "----------------------------------------"
    echo "Processing: $url"
    echo "----------------------------------------"

    # Extract stream URL (FIXED with cookies + android client)
    STREAM_URL=""

    if [[ "$url" == *"youtube.com"* || "$url" == *"youtu.be"* ]]; then

        echo "Extracting YouTube stream..."

        STREAM_URL=$(yt-dlp \
            --cookies /app/cookies.txt \
            --extractor-args "youtube:player_client=android" \
            -f "bv*+ba/best" \
            -g "$url" 2>/dev/null || true)

        if [ -z "$STREAM_URL" ]; then
            echo "⚠ Primary extraction failed, trying fallback..."

            STREAM_URL=$(yt-dlp \
                --cookies /app/cookies.txt \
                -f "best" \
                -g "$url" 2>/dev/null || true)
        fi

        if [ -z "$STREAM_URL" ]; then
            echo "❌ Failed to extract stream. Skipping..."
            sleep 10
            continue
        fi

    else
        STREAM_URL="$url"
    fi

    echo "Stream ready!"

    # FFmpeg streaming (AUTO RECOVERY ENABLED)
    ffmpeg -hide_banner -loglevel warning \
        -re \
        -i "$STREAM_URL" \
        -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" \
        -r 30 \
        -c:v libx264 -preset veryfast -tune zerolatency \
        -pix_fmt yuv420p \
        -b:v 3000k -maxrate 3000k -bufsize 6000k \
        -g 60 \
        -c:a aac -b:a 128k -ar 44100 -ac 2 \
        -f flv \
        "rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_STREAM_KEY}" \
    || echo "❌ ffmpeg crashed, restarting..."

    echo "Waiting 5 seconds..."
    sleep 5

  done

  echo "Loop completed. Restarting in 30 seconds..."
  sleep 30
done
