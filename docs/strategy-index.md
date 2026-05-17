# MedTech Strategy Layer — PRDs & ADRs

This directory contains the **Product Requirement Documents (PRDs)** and **Architecture Decision Records (ADRs)** for the MedTech Sepsis Detection Platform.

> **Zero PHI Declaration:** All data across this platform is fully synthetic (Synthea-modeled profiles). No real patient data, PHI, or PII is used anywhere. This is an educational R&D prototype.

---

## Product Requirement Documents (PRDs)

PRDs follow the **Marty Cagan framework**: Opportunity → Target Audience → Product Vision → Success Metrics → Scope → Requirements → Regulatory Alignment → Risks.

| Document | Product | Repo |
|---|---|---|
| [PRD-001](https://github.com/chaithubk/medtech-telemetry-contract/blob/main/docs/prd/PRD-001-telemetry-contract.md) | Telemetry Contract (Schema Governance) | `medtech-telemetry-contract` |
| [PRD-002](https://github.com/chaithubk/medtech-vitals-publisher/blob/main/docs/prd/PRD-002-vitals-publisher.md) | Vitals Publisher (Synthetic Telemetry Generator) | `medtech-vitals-publisher` |
| [PRD-003](https://github.com/chaithubk/medtech-edge-analytics/blob/main/docs/prd/PRD-003-edge-analytics.md) | Edge Analytics (On-Device Sepsis Inference) | `medtech-edge-analytics` |
| [PRD-004](https://github.com/chaithubk/medtech-device-os/blob/main/docs/prd/PRD-004-device-os.md) | Device OS (Hardened Yocto Embedded Linux) | `medtech-device-os` |
| [PRD-005](prd/PRD-005-platform.md) | Platform (Integration & Simulation Orchestration) | `medtech-platform` |
| [PRD-006](https://github.com/chaithubk/medtech-telemetry-cloud/blob/main/docs/prd/PRD-006-telemetry-cloud.md) | Telemetry Cloud (Population Health Backend) | `medtech-telemetry-cloud` |

---

## Architecture Decision Records (ADRs)

ADRs follow the **Nygard standard**: Context → Decision → Rationale → Consequences → Alternatives Considered → Standards References.

| Document | Decision | Status |
|---|---|---|
| [ADR-001](https://github.com/chaithubk/medtech-vitals-publisher/blob/main/docs/adr/ADR-001-contract-management-migration.md) | Contract Management Migration | Accepted |
| [ADR-002](https://github.com/chaithubk/medtech-vitals-publisher/blob/main/docs/adr/ADR-002-mqtt-for-inter-service-telemetry.md) | MQTT for Inter-Service Telemetry Transport | Accepted |
| [ADR-003](https://github.com/chaithubk/medtech-edge-analytics/blob/main/docs/adr/ADR-003-on-device-tflite-inference.md) | On-Device TFLite Inference for sepsis risk detection | Accepted |
| [ADR-004](https://github.com/chaithubk/medtech-device-os/blob/main/docs/adr/ADR-004-qemu-arm64-validation.md) | QEMU ARM64 for initial software validation before NXP i.MX8MP hardware | Accepted |
| [ADR-005](https://github.com/chaithubk/medtech-device-os/blob/main/docs/adr/ADR-005-spdx-sbom.md) | SPDX 2.2 for Software Bill of Materials (SBOM) | Accepted |

---

## Regulatory & Standards Coverage Matrix

| Standard | PRD-001 | PRD-002 | PRD-003 | PRD-004 | PRD-005 | PRD-006 |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| IEC 60601-1-8 (Alarms) | ✅ | ✅ | ✅ | ✅ | ✅ | — |
| HL7 v2.x / FHIR R4 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ISO 14971 (Risk Management) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| IEC 62304 (SW Lifecycle) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| FDA Cybersecurity Guidance 2023 | — | — | ✅ | ✅ | ✅ | — |
| FDA AI/ML SaMD Action Plan | — | — | ✅ | — | — | ✅ |
| HIPAA §164.312 | — | — | ✅ | ✅ | — | ✅ |
| SPDX / ISO 5962 | — | — | — | ✅ | — | — |

---

## How to Use These Documents

### In VS Code with Claude or GitHub Copilot

1. Open the relevant repo in VS Code
2. Copy the **repo-specific PRD** as context at the start of your session
3. Reference the relevant **ADRs** when working on architectural concerns
4. Use the [program super-context](program-context.md) to orient cross-repo work

### Document Lifecycle

- **PRDs** should be updated when product scope, success metrics, or regulatory requirements change
- **ADRs** should be updated (status → Superseded) when the underlying decision is reversed, not edited in-place
- New ADRs should be created for significant new architectural decisions
