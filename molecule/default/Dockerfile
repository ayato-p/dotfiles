FROM debian:trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    sudo \
    bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
