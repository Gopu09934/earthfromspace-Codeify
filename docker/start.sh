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
echo "Starting 24/7 YouTube Stream..."
echo "========================================"
echo "Node version:"
node --version
echo "yt-dlp version:"
yt-dlp --version
echo "ffmpeg version:"
ffmpeg -version | head -1
echo "========================================"

IFS=',' read -ra URLS <<< "$VIDEO_URL"

while true; do
    for url in "${URLS[@]}"; do
        echo "----------------------------------------"
        echo "Processing: $url"
        echo "----------------------------------------"
        
        INPUT_URL="$url"
        
        # Extract video from YouTube
        if [[ "$url" == *"youtube.com"* || "$url" == *"youtu.be"* ]]; then
            echo "Detecting YouTube URL, extracting stream..."
            
            # Try to get the direct stream URL using yt-dlp with Node.js runtime
            if INPUT_URL=$(yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" -g "$url" 2>&1); then
                echo "✓ Stream URL extracted successfully"
            else
                echo "✗ Failed to extract with best format, trying alternative..."
                # Fallback: try with HLS format (better for live streams)
                if INPUT_URL=$(yt-dlp -f "best" -g "$url" 2>&1); then
                    echo "✓ Fallback stream URL extracted"
                else
                    echo "✗ All extraction methods failed. Check YouTube privacy settings."
                    echo "Waiting before retry..."
                    sleep 10
                    continue
                fi
            fi
        fi
        
        echo "Starting ffmpeg stream with URL: ${INPUT_URL:0:50}..."
        
        # Stream to YouTube with error handling
        if ffmpeg \
            -hide_banner \
            -loglevel warning \
            -re \
            -i "$INPUT_URL" \
            -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" \
            -r 30 \
            -c:v libx264 \
            -preset ultrafast \
            -tune zerolatency \
            -pix_fmt yuv420p \
            -b:v 3000k \
            -maxrate 3000k \
            -bufsize 6000k \
            -g 60 \
            -keyint_min 60 \
            -c:a aac \
            -b:a 128k \
            -ar 44100 \
            -ac 2 \
            -f flv \
            "rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_STREAM_KEY}"; then
            echo "✓ Stream completed successfully"
        else
            echo "✗ ffmpeg streaming failed with exit code: $?"
        fi
        
        echo "Finished streaming"
        echo "Waiting 5 seconds before next URL..."
        sleep 5
    done
    
    echo ""
    echo "Completed all URLs, restarting loop..."
    echo "Next attempt in 30 seconds..."
    sleep 30
done
