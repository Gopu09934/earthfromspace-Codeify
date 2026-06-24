name: Stream

on:
  workflow_dispatch:
  schedule:
    - cron: "0 */5 * * *"

jobs:
  stream:
    runs-on: ubuntu-latest
    timeout-minutes: 360
    permissions:
      contents: read
    
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build Docker Image
        run: |
          docker build \
            --progress=plain \
            -t yt-stream:latest \
            -f ./docker/Dockerfile \
            ./docker/
        timeout-minutes: 30

      - name: Verify Docker Image
        run: |
          docker images | grep yt-stream
          docker run --rm yt-stream:latest yt-dlp --version

      - name: Start Stream
        run: |
          docker run \
            --rm \
            -e VIDEO_URL="${{ secrets.VIDEO_URL }}" \
            -e YOUTUBE_STREAM_KEY="${{ secrets.YOUTUBE_STREAM_KEY }}" \
            --name yt-stream-container \
            yt-stream:latest
        timeout-minutes: 355
        continue-on-error: true

      - name: Upload Logs
        if: failure()
        run: |
          echo "Stream job failed. Check logs above for details."
          exit 1
