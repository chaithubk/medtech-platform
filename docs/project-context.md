# Project Context — MedTech Platform

## Project summary
This repository is the Docker-based integration and simulation platform for the MedTech program.

It exists to help validate the full stack in a reproducible containerized environment and to keep the broader program aligned.

---

## Current program intent
The platform is expected to:
- simulate MedTech service behavior
- coordinate containerized workflows
- validate the shared telemetry contract
- support local integration testing
- help review overall program progress

---

## Current concerns
- simulation drift from the real device OS
- message schema mismatches
- unclear repo boundary between Docker orchestration and QEMU/Linux runtime
- integration tests that do not reflect real MedTech messages

---

## Milestones
### Milestone 1
- Docker-based orchestration is clear and working
- simulation reflects the device/cloud data flow
- telemetry contract is aligned

### Milestone 2
- integration tests validate the full stack
- simulated messages are representative
- the platform helps prove program cohesion

### Milestone 3
- program-level review and progress tracking are reliable
- the platform acts as a stable simulation anchor for the ecosystem

---

## Operational checklist
- [ ] Repo remains Docker-based
- [ ] Simulation matches the shared telemetry contract
- [ ] It does not overlap with device OS responsibilities
- [ ] Integration tests are meaningful
- [ ] It supports the broader MedTech program
- [ ] No schema drift across repos

---

## Review guidance
When working in this repo:
- keep it orchestration-focused
- keep it simulation-focused
- do not turn it into a device OS repo
- keep message formats aligned
- make it useful for system-level validation

---

## Status note
This repo is part of the larger MedTech program, but it is specifically the Docker-based platform/simulation layer.