cat > README.md << 'EOF'
# MedTech Integration Platform

Complete integration of three repositories for real-time sepsis detection and clinical dashboard.

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
├── README.md
├── .gitignore
│
├── medtech-vitals-publisher/     (Submodule)
├── medtech-clinician-ui/         (Submodule)
└── medtech-edge-analytics/       (Submodule)
```