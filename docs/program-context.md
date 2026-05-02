# Program Context — MedTech Platform

## Purpose
This repository is the **Docker-based orchestration and simulation platform** for the MedTech program.

It should be used as the integration and simulation layer for the broader MedTech ecosystem, not as the device OS itself.

---

## Role in the MedTech program
This repo owns:
- Docker and Docker Compose orchestration
- full-stack simulation
- local integration workflows
- program-level aggregation and coordination
- validation of the shared telemetry contract in a containerized environment

This repo does **not** own:
- the Yocto/QEMU device runtime
- the clinician UI source code
- the edge analytics application logic
- the cloud telemetry backend implementation

---

## Architecture expectations
### Platform behavior
- Docker-based
- reproducible
- useful for full-stack simulation
- aligned with the MedTech telemetry contract
- easy to run for local validation

### Platform responsibilities
- simulate or orchestrate the MedTech stack
- validate system-level flow
- support integration testing
- help track overall program progress

---

## Shared telemetry contract
### Vitals payload
- timestamp
- hr
- bp_sys
- bp_dia
- o2_sat
- temperature
- quality
- source

### Prediction payload
- timestamp
- risk_score
- risk_level
- confidence
- model_latency_ms

The platform simulation should mirror this contract exactly.

---

## On-track criteria
This repo is on track if:
- it remains clearly Docker-based
- it supports simulation or orchestration
- it helps validate the end-to-end MedTech workflow
- the shared telemetry contract stays consistent
- it stays easy to understand and run

---

## Deviation signals
This repo is drifting if:
- it is treated like the device OS
- it conflates Docker simulation with Yocto/QEMU runtime
- telemetry schemas diverge from the other repos
- it becomes a dumping ground for unrelated orchestration logic
- simulation no longer resembles the real system

---

## Current priorities
1. Keep this repo clearly Docker-based
2. Use it as the orchestration/simulation layer
3. Keep the telemetry contract aligned with the rest of the program
4. Use it to validate program progress and integration
5. Keep it as the main place for program-wide review if needed

---

## Review questions
When reviewing changes here:
- Does this belong in the Docker-based platform?
- Does it improve simulation or orchestration?
- Does it help validate the MedTech workflow?
- Does it preserve the shared telemetry contract?
- Does it keep the platform separate from the device OS?
- Does it improve the coherence of the whole program?

---

## Summary
`medtech-platform` is the Docker-based orchestration and simulation repo.

It should remain focused on:
- Docker Compose
- full-stack simulation
- integration coordination
- telemetry alignment
- program-level review and status

It is not the QEMU/Yocto device OS repo.