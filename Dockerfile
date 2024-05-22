# Use the official n8n image from n8n.io as the base
FROM docker.n8n.io/n8nio/n8n

# Switch to root to install packages
USER root

# Install Docker CLI and ffmpeg
RUN apk add --no-cache docker-cli ffmpeg

# Create the docker group if it does not exist and add the 'node' user to it
RUN addgroup -S docker || true
RUN addgroup node docker

# Switch back to the default user 'node'
USER node
```

#### `docker-compose.service`

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
