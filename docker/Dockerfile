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
    || (apt-get update && apt-get install -y \
        ffmpeg curl ca-certificates python3 python3-pip)

RUN pip3 install --no-cache-dir -U yt-dlp

WORKDIR /app

COPY start.sh .

RUN chmod +x start.sh

CMD ["bash", "./start.sh"]
