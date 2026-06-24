FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        curl \
        ca-certificates \
        python3 \
        python3-pip \
        git \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (for yt-dlp JavaScript runtime)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install yt-dlp
RUN pip3 install --no-cache-dir yt-dlp

# Verify installations
RUN ffmpeg -version | head -1 && \
    yt-dlp --version && \
    node --version

WORKDIR /app
COPY start.sh .
RUN chmod +x start.sh

CMD ["bash", "./start.sh"]
