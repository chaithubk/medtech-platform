# AI Context — MedTech Platform

This repository is the **Docker-based orchestration and simulation platform** for the MedTech program.

## What this repo owns
- Docker-based orchestration
- Docker Compose simulation
- full-stack MedTech integration environment
- local simulation and validation workflows
- program-level coordination and status tracking

## What this repo does not own
- the Yocto/QEMU device OS image
- the embedded Linux runtime
- the clinician UI source code
- the edge analytics application itself
- the cloud telemetry backend itself

## Program relationship
This repo is one part of the larger MedTech system. The other repos are:
- `medtech-device-os` — QEMU / Yocto Linux device OS
- `medtech-vitals-publisher` — vitals simulation via MQTT
- `medtech-edge-analytics` — local sepsis prediction
- `medtech-clinician-ui` — Qt6 bedside dashboard
- `medtech-telemetry-cloud` — cloud telemetry ingestion and dashboards

## Key instruction for AI
Treat this repo as the **Docker-based simulation/orchestration layer**.  
Keep changes aligned with:
- Docker Compose workflow
- full-stack simulation
- shared telemetry contract
- end-to-end validation
- program progress tracking

## Shared telemetry contract
- vitals: timestamp, hr, bp_sys, bp_dia, o2_sat, temperature, quality, source
- prediction: timestamp, risk_score, risk_level, confidence, model_latency_ms

If a change affects this contract, it must be coordinated across the program.

## Canonical references
- `docs/program-context.md`
- `docs/project-context.md`