#!/bin/bash

# input wallet address
read -p "Masukkan Wallet Address: " WALLET_ADDRESS

# input worker name
read -p "Masukkan Nama Worker: " WORKER_NAME

# Touch Dockerfile
cat > Dockerfile <<EOL
# Gunakan base image Debian ringan
FROM debian:bullseye-slim

# Set direktori kerja di dalam container
WORKDIR /app

# Salin binary ke dalam container
COPY iniminer-linux-x64 /app/iniminer-linux-x64

# Beri izin eksekusi pada binary
RUN chmod +x /app/iniminer-linux-x64

# Perintah default hanya menjalankan binary
CMD ["/app/iniminer-linux-x64"]
EOL

# Touch file docker-compose.yml
cat > docker-compose.yml <<EOL
version: "3.8"
services:
  iniminer:
    pull_policy: always
    restart: on-failure
    build:
      context: .
    container_name: iniminer-service
    command: >
      /app/iniminer-linux-x64 --pool stratum+tcp://${WALLET_ADDRESS}.${WORKER_NAME}@pool-core-testnet.inichain.com:32672 --cpu-devices 1 --cpu-devices 2
    tty: true
    volumes:
      - ./iniminer-linux-x64:/app/iniminer-linux-x64
EOL

# Run Docker Compose
docker-compose -f docker-compose.yml up -d
