FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Update apt sources and install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        curl \
        wget \
        ca-certificates \
        python3 \
        python3-pip \
        git \
    && rm -rf /var/lib/apt/lists/*

# Install yt-dlp binary (most reliable method)
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o /usr/local/bin/yt-dlp && \
    chmod +x /usr/local/bin/yt-dlp && \
    yt-dlp --version

# Verify ffmpeg is installed
RUN ffmpeg -version | head -n 1

WORKDIR /app

COPY start.sh .
RUN chmod +x start.sh

CMD ["bash", "./start.sh"]
