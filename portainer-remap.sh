# To remap and expose Portainer via nginx at https://truenas.ossevoort.net/portainer/
# 1) stop/remove existing container
# 2) run it on 9443/9000 with the same data dir
# 3) nginx already proxies /portainer/ to host:9443

# Stop and remove old container (adjust name if different)
docker stop ix-portainer-portainer-1 || true
docker rm ix-portainer-portainer-1 || true

# Start Portainer on standard ports with your data dir
# (keeps data in /mnt/z1/portainer)
docker run -d --name ix-portainer-portainer-1 \
  -p 9443:9443 -p 9000:9000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /mnt/z1/portainer:/data \
  portainer/portainer-ce:2.38.1

# After start, nginx /portainer/ path will forward to https://host:9443
