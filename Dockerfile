FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    wget \
    tar \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m rustserv

USER rustserv
WORKDIR /home/rustserv

RUN mkdir /home/rustserv/steamcmd && \
    cd /home/rustserv/steamcmd && \
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xvzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

WORKDIR /home/rustserv

ENTRYPOINT ["bash"]

