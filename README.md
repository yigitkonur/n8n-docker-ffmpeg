# n8n with ffmpeg and Docker Compose

This repository provides a Docker Compose setup for running n8n with ffmpeg support. It also includes instructions for setting up the service to run on system startup using systemd.

## Prerequisites

- Docker: [Install Docker](https://docs.docker.com/get-docker/)
- Docker Compose: [Install Docker Compose](https://docs.docker.com/compose/install/)

## Setup

### 1. Clone the Repository

Open a terminal and run the following commands:

```bash
git clone https://github.com/yourusername/n8n-docker-ffmpeg.git
cd n8n-docker-ffmpeg
```

### 2. Create a `.env` File

Create a file named `.env` in the root of the repository and add the following variables:

```env
N8N_HOST=n8n.local
N8N_PORT=5678
N8N_PROTOCOL=https
NODE_ENV=production
WEBHOOK_URL=https://n8n.local/
GENERIC_TIMEZONE=America/New_York
```

### 3. Build and Run the Containers

Build the Docker containers and start the services:

```bash
docker-compose build --no-cache
docker-compose up -d
```

### 4. Access n8n

Open your browser and go to `https://n8n.local`.

## Setting up as a Systemd Service

To ensure the Docker Compose services start on system boot, follow these steps:

### 1. Create the Systemd Service File

Create a new systemd service file:

```bash
sudo nano /etc/systemd/system/docker-compose.service
```

Copy the following content into the file:

```ini
[Unit]
Description=Docker Compose Service
After=network.target docker.service
Requires=docker.service

[Service]
Type=oneshot
User=root
WorkingDirectory=/path/to/your/n8n-docker-ffmpeg
ExecStart=/usr/bin/docker-compose build --no-cache
ExecStartPost=/usr/bin/docker-compose up -d
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

### 2. Reload Systemd and Enable the Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable docker-compose.service
sudo systemctl start docker-compose.service
```

### Manual Startup

If you prefer to start the services manually, navigate to the project directory and run:

```bash
cd /path/to/your/n8n-docker-ffmpeg
docker-compose build --no-cache
docker-compose up -d
```

## Volumes

- `caddy_data`: Stores Caddy server data.
- `n8n_data`: Stores n8n workflow data.

## Additional Information

- The `Dockerfile` installs Docker CLI and ffmpeg inside the n8n container to enable additional functionality.
- Ensure that the `caddy_config` directory and `Caddyfile` are correctly set up in your project directory.

For more detailed instructions and troubleshooting, please refer to the official documentation of [Docker](https://docs.docker.com/) and [n8n](https://docs.n8n.io/).
