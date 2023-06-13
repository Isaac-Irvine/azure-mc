# Setup minecraft
docker pull itzg/minecraft-server
mkdir data
docker run \
  --rm \
  -v $(pwd)/data:/data \
  -e EULA=TRUE \
  -e VERSION=1.19.4 \
  -e TYPE=PAPER \
  -e MEMORY=3000M \
  -e RCON_CMDS_STARTUP=stop \
  itzg/minecraft-server
wget \
  https://saggyresourcepack.blob.core.windows.net/www/PreGen-1.0.jar \
  https://saggyresourcepack.blob.core.windows.net/www/Chunky-1.3.52.jar \
  -P \
  ./data/plugins

# Run benchmark
/usr/bin/time -o time.txt -f %E \
  docker run \
    --rm \
    -v $(pwd)/data:/data \
    -e EULA=TRUE \
    -e VERSION=1.19.4 \
    -e TYPE=PAPER \
    -e MEMORY=10000M \
    itzg/minecraft-server

# TODO: Update time.txt somewhere