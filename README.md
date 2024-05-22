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

### Using n8n with ffmpeg

With ffmpeg installed in your n8n Docker container, you can leverage the power of ffmpeg directly within your n8n workflows. This allows you to process media files as part of your automation sequences.

#### Example: Convert MP4 to MP3

In this example, we'll demonstrate how to use the Execute Command node in n8n to convert an MP4 video file to an MP3 audio file.

1. **Add the Execute Command Node**

   - Open your n8n editor and create a new workflow.
   - Add an "Execute Command" node to your workflow.

2. **Configure the Execute Command Node**

   - Set the "Command" field to the ffmpeg command for converting MP4 to MP3.
   - Example command:

     ```bash
     ffmpeg -i /files/input-video.mp4 -q:a 0 -map a /files/output-audio.mp3
     ```

   - Here's the detailed configuration:

     - **Command**: `ffmpeg`
     - **Parameters**: `-i /files/input-video.mp4 -q:a 0 -map a /files/output-audio.mp3`

3. **Place Input File and Define Output Location**

   - Ensure the input MP4 file (`input-video.mp4`) is placed in the `/files` directory within your n8n container.
   - The converted MP3 file (`output-audio.mp3`) will be saved in the same directory.

4. **Execute the Workflow**

   - Execute the workflow to run the ffmpeg command.
   - Check the `/files` directory for the newly created `output-audio.mp3` file.

#### Detailed Steps

1. **Place the Input File**: Copy your MP4 file to the `local_files` directory on your host machine, which maps to `/files` inside the n8n container.

   ```bash
   cp /path/to/your/input-video.mp4 /path/to/n8n-docker-ffmpeg/local_files/
   ```

2. **Create and Configure the Workflow**: Follow the steps above to create a workflow in n8n and configure the Execute Command node.

3. **Run the Workflow**: Execute your workflow in n8n. After the workflow completes, you can find the converted MP3 file in the `local_files` directory.

### Benefits

- **Automation**: Automate media file conversions as part of larger workflows.
- **Flexibility**: Use any ffmpeg command within n8n for various media processing tasks.
- **Ease of Use**: Simplify media processing tasks without leaving your n8n environment.

By following these steps, you can easily incorporate media processing into your n8n workflows, leveraging the powerful capabilities of ffmpeg directly within your automation sequences.
