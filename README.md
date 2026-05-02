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

### Clone with Submodules
```bash
git clone --recurse-submodules git@github.com:chaithubk/medtech-platform.git
cd medtech-platform
```

### Run Integrated System

```
# Build all services
docker-compose build

# Start all services
docker-compose up

# In another terminal, monitor MQTT
docker-compose logs -f
```

### View Logs

```
# All services
docker-compose logs -f

# Individual service
docker-compose logs -f vitals-publisher
docker-compose logs -f edge-analytics
docker-compose logs -f clinician-ui
```

### Stop All Services

```
docker-compose down
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