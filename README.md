# MedTech Integration Platform

Complete integration of three repositories for real-time sepsis detection and clinical dashboard.

## Program Context

This repository is the Docker-based orchestration and simulation platform for the MedTech program.

### Context files
- [AI Context](docs/ai-context.md)
- [Program Context](docs/program-context.md)
- [Project Context](docs/project-context.md)

These files describe the platform/simulation role, the shared telemetry contract, and the current program direction.

## Services

- **medtech-vitals-publisher** (Python) - Generates/publishes vital signs via MQTT
- **medtech-edge-analytics** (Python) - TensorFlow Lite sepsis detection model
- **medtech-clinician-ui** (C++/Qt6) - Real-time dashboard for clinicians

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Git with SSH configured
- MQTT Explorer (optional, for monitoring)

### Run from GHCR (no clone required)

The published platform image bundles the compose manifest and entrypoint CLI.
A single `docker run` pulls all service images and streams the full stack:

```bash
# Foreground — logs streamed to your terminal (Ctrl-C or docker stop to quit)
docker run --rm -it --name medtech-platform \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/chaithubk/medtech-platform:latest

# Detached — stack runs in the background
docker run -d --name medtech-platform \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/chaithubk/medtech-platform:latest up -d
```

> **Note:** `-v /var/run/docker.sock:/var/run/docker.sock` is required.
> The platform image orchestrates sibling containers and therefore needs
> access to the host Docker daemon. Without it the container will print a
> clear error with the corrected command and exit.

#### Operator subcommands

```bash
# Tail all service logs
docker exec medtech-platform medtech-platform logs -f

# Check service status
docker exec medtech-platform medtech-platform ps

# Pull the latest pinned images
docker exec medtech-platform medtech-platform pull

# Stop and remove the stack
docker exec medtech-platform medtech-platform down

# Validate the bundled compose file
docker exec medtech-platform medtech-platform config
```

#### Platform ports

| Port | Service |
|------|---------|
| `1883` | MQTT broker (vitals-publisher) |

### Clone with Submodules

```bash
git clone --recurse-submodules git@github.com:chaithubk/medtech-platform.git
cd medtech-platform
```

### Run Integrated System (after cloning)

```bash
# Start all services (foreground)
docker compose up

# Or pull pre-built images first
docker compose pull
docker compose up
```

### Build from Source (local development)

```bash
# Build images from local submodule source and start
docker compose -f docker-compose.yml -f docker-compose.build.yml up --build
```

### View Logs

```bash
# All services (after docker compose up)
docker compose logs -f

# Individual service
docker compose logs -f vitals-publisher
docker compose logs -f edge-analytics
docker compose logs -f clinician-ui
```

### Stop All Services

```bash
docker compose down
```

## Architecture

```
Vitals Publisher (MQTT Broker + Generator)
    ↓ medtech/vitals/latest
    
Edge Analytics (Sepsis Detection)
    ↓ medtech/predictions/sepsis
    
Clinician UI (Dashboard)
```

## Testing with MQTT Explorer

1. Install: https://mqtt-explorer.com/
2. Connect to: localhost:1883
3. Subscribe to: medtech/#
4. See real-time data flow

## Updating Submodules

```
# Update all submodules to latest
git submodule update --remote

# Update specific submodule
cd medtech-vitals-publisher
git pull origin main
cd ..
git add medtech-vitals-publisher
git commit -m "chore: update vitals-publisher"
git push origin main
```

## Repository Structure

```
medtech-platform/
├── .git/
├── .gitmodules
├── docker-compose.yml
├── docker-compose.build.yml
├── docker/
│   └── entrypoint.sh          (container entrypoint CLI)
├── Dockerfile
├── README.md
├── .gitignore
│
├── medtech-vitals-publisher/     (Submodule)
├── medtech-clinician-ui/         (Submodule)
└── medtech-edge-analytics/       (Submodule)
```

## Docker Compose Files Explained

The platform uses two Docker Compose files for different scenarios:

- **docker-compose.yml**
  - **Purpose:** Main manifest for production, CI, and integration testing.
  - **Behavior:** Pins all services to pre-built images from GHCR (GitHub Container Registry).
  - **Usage:**
    - To run the latest validated platform stack:
      ```bash
      docker compose pull
      docker compose up
      ```
    - No local build or source code is required.

- **docker-compose.build.yml**
  - **Purpose:** Local development override for building images from source.
  - **Behavior:** Replaces image references with build instructions for each service, so you can build from the local submodule source code.
  - **Usage:**
    - To build and run all services from local source:
      ```bash
      docker compose -f docker-compose.yml -f docker-compose.build.yml up --build
      ```
    - Useful for development and testing changes before publishing images.

> **Note:**
> - `docker-compose.yml` is always used as the base file.
> - `docker-compose.build.yml` is only needed for local development. It is not used in CI or production.