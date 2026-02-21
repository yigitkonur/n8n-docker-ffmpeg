docker compose setup for running n8n with FFmpeg and Docker CLI baked into the image. Caddy sits in front for automatic HTTPS. the whole stack auto-starts on boot via systemd.

```bash
docker compose up -d
```

[![docker](https://img.shields.io/badge/docker-compose_3.7-93450a.svg?style=flat-square)](https://docs.docker.com/compose/)
[![n8n](https://img.shields.io/badge/n8n-official_image-93450a.svg?style=flat-square)](https://n8n.io/)
[![license](https://img.shields.io/badge/license-MIT-grey.svg?style=flat-square)](https://opensource.org/licenses/MIT)

---

## what it does

extends the official n8n Alpine image with two packages:

- **FFmpeg** — so n8n workflows can transcode, convert, and manipulate audio/video via execute command nodes
- **docker-cli** — so n8n workflows can control the host Docker daemon through the mounted socket

the `node` user (n8n's runtime user) gets added to the `docker` group for socket access without root.

## the stack

two containers on a shared compose network:

| service | image | role |
|:---|:---|:---|
| `n8n` | custom build from `Dockerfile` | workflow engine on port 5678, FFmpeg + Docker CLI available |
| `caddy` | `caddy:latest` | TLS-terminating reverse proxy on 80/443, auto Let's Encrypt certs |

### volumes

| volume | type | what it stores |
|:---|:---|:---|
| `n8n_data` | external, named | workflows, credentials, execution history (`/home/node/.n8n`) |
| `caddy_data` | external, named | TLS certificates and ACME state |
| `./local_files` | bind mount | shared file staging area at `/files` — drop media in, FFmpeg outputs land here |
| `/var/run/docker.sock` | bind mount | host Docker socket, gives n8n container control over host daemon |

both named volumes are `external: true` — you need to create them before first run. this is intentional to prevent accidental data loss from `docker compose down -v`.

## setup

### 1. create volumes

```bash
docker volume create n8n_data
docker volume create caddy_data
```

### 2. configure environment

edit `.env` or set values directly in `docker-compose.yml`:

```env
N8N_HOST=n8n.local
N8N_PORT=5678
N8N_PROTOCOL=https
NODE_ENV=production
WEBHOOK_URL=https://n8n.local/
GENERIC_TIMEZONE=America/New_York
```

replace `n8n.local` with your actual domain or add it to `/etc/hosts`.

### 3. add a Caddyfile

create `caddy_config/Caddyfile` to proxy traffic to n8n:

```
n8n.local {
    reverse_proxy n8n:5678
}
```

### 4. run

```bash
docker compose up -d
```

n8n is at `https://n8n.local`. direct access also available at `http://localhost:5678`.

## auto-start on boot

create a systemd unit at `/etc/systemd/system/docker-compose.service`:

```ini
[Unit]
Description=Docker Compose Service
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
User=root
WorkingDirectory=/path/to/your/n8n-ffmpeg-stack
ExecStart=/usr/bin/docker compose build --no-cache
ExecStartPost=/usr/bin/docker compose up -d
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

then enable it:

```bash
sudo systemctl enable --now docker-compose.service
```

rebuilds the image fresh and starts the stack on every boot.

## example workflow

drop a video into `local_files/`, then use an n8n execute command node:

```bash
ffmpeg -i /files/input-video.mp4 -q:a 0 -map a /files/output-audio.mp3
```

the output lands in `local_files/` on the host. n8n can then continue the workflow — upload to cloud storage, send a notification, call an API, whatever.

## security note

the Docker socket mount gives the n8n container root-equivalent access to the host. don't expose this to untrusted users or the open internet without additional safeguards.

## license

MIT
