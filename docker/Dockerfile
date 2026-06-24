FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's|http://archive.ubuntu.com|http://security.ubuntu.com|g' /etc/apt/sources.list || true

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        curl \
        ca-certificates \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir yt-dlp

WORKDIR /app

COPY start.sh .
RUN chmod +x start.sh

CMD ["bash", "./start.sh"]
