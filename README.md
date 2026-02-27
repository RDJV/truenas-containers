# TrueNAS Portainer AI Stack

Services: OpenWebUI (LLM UI), Ollama (models runtime), SearxNG (meta search), ComfyUI (SD workflows), and Nginx as the single entrypoint.

## Routing (single domain)
- Domain: `truenas.ossevoort.local`
- Paths:
  - `/chat/` -> OpenWebUI
  - `/searxng/` -> SearxNG (JSON default for API callers like OpenWebUI)
  - `/comfy/` -> ComfyUI
  - `/truenas/` -> TrueNAS UI (prefers 8443 https, falls back to 8080 http)
  - `/portainer/` -> Portainer UI (proxied to host port 9443)
  - `/` redirects to `/chat/`

## Files
- `docker-compose.yml`
- `nginx/conf.d/default.conf` (path-based routing + HTTPS + ACME webroot)
- `searxng/settings.yml` (set your own `secret_key`)
- `portainer-remap.sh` (helper to run Portainer on 9443/9000)

## Storage (bind mounts on TrueNAS)
- `/mnt/z1/truenas-containers/data/ollama` -> Ollama models
- `/mnt/z1/truenas-containers/data/openwebui` -> OpenWebUI data
- `/mnt/z1/truenas-containers/data/comfyui/workspace` -> ComfyUI models/outputs/custom nodes
- `/mnt/z1/truenas-containers/data/searxng/cache` -> SearxNG cache
- `/mnt/z1/truenas-containers/data/searxng/redis` -> Redis data
- `/mnt/z1/truenas-containers/data/letsencrypt` (named volume in Docker) -> TLS certs (mounted into nginx/certbot)

## Resource limits (per service)
- nginx: 512m RAM
- openwebui: 4g RAM
- searxng: 1g RAM
- searxng-redis: 512m RAM
- ollama: 10g RAM, GPU requested
- comfyui: 10g RAM, GPU requested
Note: On a single Docker host, some Portainer versions ignore `deploy.*` limits; set limits in the Portainer UI if needed.

## GPU requirements
- Host must have NVIDIA drivers and `nvidia-container-toolkit` configured. Env vars and deploy GPU reservations are already set. If GPUs don’t appear, set Docker default runtime to `nvidia` or enable `--gpus all` for services in Portainer.

## TLS
- TLS removed in this setup; everything runs over HTTP on port 80 behind your internal network. If you later move to a public domain, reintroduce TLS/certbot and update nginx accordingly.

## Quick start (Portainer stack)
1) Clone on the host (recommended path):
   ```
   git clone https://github.com/RDJV/truenas-containers.git /mnt/z1/truenas-containers
   cd /mnt/z1/truenas-containers
   ```
2) Ensure `/mnt/z1/truenas-containers/data/...` directories exist and are writable.
3) In Portainer: Stacks -> **Add stack** -> **Upload** -> select `docker-compose.yml` -> **Deploy the stack**.
4) Point DNS `truenas.ossevoort.net` to the TrueNAS Docker host IP and open ports 80/443 to the host for ACME.
5) Run the one-time certbot command above to fetch certs, then restart nginx.
6) Browse:
   - https://truenas.ossevoort.local/truenas/
   - https://truenas.ossevoort.local/chat/
   - https://truenas.ossevoort.local/searxng/
   - https://truenas.ossevoort.local/comfy/
   - https://truenas.ossevoort.local/portainer/

## TLS (optional extras)
- Provide your own certs by placing them in `/mnt/z1/truenas-containers/data/letsencrypt/live/truenas.ossevoort.net/` and restart nginx.

## Keep in sync with GitHub
- Git remote: `https://github.com/RDJV/truenas-containers.git`
- Update on the server before redeploying:
  ```
  cd /mnt/z1/truenas-containers
  git pull
  docker compose pull    # optional, to refresh images
  docker compose up -d   # or redeploy via Portainer
  ```
- Portainer option: create the stack from the Git repo URL and enable “Auto-update” so Portainer pulls the latest on webhook/interval.
