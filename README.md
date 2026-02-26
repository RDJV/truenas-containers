# TrueNAS Portainer AI Stack

Services: OpenWebUI (LLM UI), Ollama (models runtime), SearxNG (meta search), ComfyUI (SD workflows), and Nginx as the single entrypoint.

## Routing (single domain)
- Domain: `truenas.ossevoort.net`
- Paths:
  - `/chat/` -> OpenWebUI
  - `/search/` -> SearxNG (JSON default for API callers like OpenWebUI)
  - `/comfy/` -> ComfyUI
  - `/ollama/` -> Ollama API (optional)
  - `/truenas/` -> TrueNAS UI (prefers 8443 https, falls back to 8080 http)
  - `/` redirects to `/chat/`

## Files
- `docker-compose.yml`
- `nginx/conf.d/default.conf` (path-based routing)
- `searxng/settings.yml` (set your own `secret_key`)

## Storage (bind mounts on TrueNAS)
- `/z1/data/apps/ollama` -> Ollama models
- `/z1/data/apps/openwebui` -> OpenWebUI data
- `/z1/data/apps/comfyui/workspace` -> ComfyUI models/outputs/custom nodes
- `/z1/data/apps/searxng/cache` -> SearxNG cache
- `/z1/data/apps/searxng/redis` -> Redis data

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

## Quick start (Portainer stack)
1) Ensure `/z1/data/apps/...` directories exist and are writable.
2) In Portainer: Stacks -> **Add stack** -> **Upload** -> select `docker-compose.yml` -> **Deploy the stack**.
3) Point DNS/hosts `truenas.ossevoort.net` to the TrueNAS Docker host IP.
4) Browse:
   - https://truenas.ossevoort.net/truenas/ (or http if cert not trusted)
   - http://truenas.ossevoort.net/chat/
   - http://truenas.ossevoort.net/search/
   - http://truenas.ossevoort.net/comfy/
   - http://truenas.ossevoort.net/ollama/

## TLS (optional)
- Terminate TLS in Nginx by adding cert/key and `listen 443 ssl;` blocks in `nginx/conf.d/default.conf`. If you use another reverse proxy (Traefik/Certbot on TrueNAS), keep this Nginx internal.
