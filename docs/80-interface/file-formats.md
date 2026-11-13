# File formats

Status: Draft

## 1. Purpose

An implementation and an adopter need to know where each artifact lives, what
format it uses, and how it is validated. This document defines the repository
layout and the schema index.

## 2. Root layout

```text
mycelia.yaml              # factory configuration
opencode.json             # OpenCode runtime configuration
AGENTS.md                 # operating contract
CONTRIBUTING.md           # human contribution guide
schemas/                  # JSON Schemas
examples/                 # validated examples
docs/                     # normative specification
.opencode/
  agents/                 # role definitions
  commands/               # prompt templates
  skills/                 # procedural knowledge
  plugins/                # optional, reviewed
runs/                     # generated run state (not committed by default)
evidence/                 # generated or external evidence
trace/                    # generated trace export
readiness/                # generated readiness reports
```

## 3. Formats

| Artifact | Format | Why |
| --- | --- | --- |
| Factory configuration | YAML | Human-authored, comments, multi-line |
| Runtime configuration | JSON | Validated against the OpenCode schema |
| Schemas | JSON Schema 2020-12 | Tooling and validation |
| Records | YAML | Human-readable audit records |
| Trace | JSONL | Append-only event stream |
| Specifications | Markdown | Reviewable, lintable |
| Machine output | JSON | Scriptable |
| Human summary | Markdown | Readable |

## 4. Naming and IDs

| Artifact | Pattern | Example |
| --- | --- | --- |
| Work item | `MYC-<n>` | `MYC-123` |
| Run | `RUN-<n>` | `RUN-001` |
| Evidence | `EVD-<TYPE>-<n>` | `EVD-LINT-001` |
| Manifest | `EM-<n>` | `EM-001` |
| Policy decision | `PD-<n>` | `PD-001` |
| Review | `REV-<n>` | `REV-001` |
| Acceptance | `ACC-<n>` | `ACC-001` |
| Release | `REL-<n>` | `REL-001` |
| Trace event | `EVT-<TYPE>-<n>` | `EVT-TOOL-001` |
| Provenance | `PRV-<n>` | `PRV-001` |
| Evaluation | `EVA-<n>` | `EVA-001` |
| Incident | `INC-<n>` | `INC-001` |
| Readiness | `RPT-<n>` | `RPT-001` |
| Handoff | `HND-<n>` | `HND-001` |
| Test integrity | `TIR-<n>` | `TIR-001` |

File names use lower-case kebab-case. Agent, command, and skill IDs use
lower-case kebab-case.

## 5. Schema index

| Schema | Kind | Example |
| --- | --- | --- |
| `work-item.schema.json` | `WorkItem` | `work-item.example.yaml` |
| `role-contract.schema.json` | `RoleContract` | `role-contract.example.yaml` |
| `policy-decision.schema.json` | `PolicyDecision` | `policy-decision.example.yaml` |
| `evidence-manifest.schema.json` | `EvidenceManifest` | `evidence-manifest.example.yaml` |
| `evidence.schema.json` | `Evidence` | `evidence.example.yaml` |
| `run-state.schema.json` | `RunState` | `run-state.example.yaml` |
| `handoff.schema.json` | `Handoff` | `handoff.example.yaml` |
| `test-integrity-report.schema.json` | `TestIntegrityReport` | `test-integrity-report.example.yaml` |
| `review-record.schema.json` | `ReviewRecord` | `review-record.example.yaml` |
| `acceptance-record.schema.json` | `AcceptanceRecord` | `acceptance-record.example.yaml` |
| `release-record.schema.json` | `ReleaseRecord` | `release-record.example.yaml` |
| `trace-event.schema.json` | `TraceEvent` | `trace-event.example.yaml` |
| `provenance-record.schema.json` | `ProvenanceRecord` | `provenance-record.example.yaml` |
| `evaluation-record.schema.json` | `EvaluationRecord` | `evaluation-record.example.yaml` |
| `incident-record.schema.json` | `IncidentRecord` | `incident-record.example.yaml` |
| `mycelia.schema.json` | `MyceliaConfig` | `mycelia.example.yaml` |
| `readiness-report.schema.json` | `ReadinessReport` | `readiness-report.example.yaml` |

## 6. Validation

```sh
mise run lint:schemas
```

The task:

1. validates every schema against the 2020-12 meta-schema;
2. validates every example against its schema.

A new schema updates:

- the file in `schemas/`
- the example in `examples/`
- `schemas/README.md`
- `mise.toml` and the CI job
- the traceability matrix

## 7. Versioning

- Every document and record uses `apiVersion: mycelia/v1`.
- Schema `$id` values are stable.
- An additive optional field can stay in v1.
- A required field, a removal, or a semantic change needs a new major version.
- A deprecated field is documented for at least one minor release.

## 8. Committed, generated, or ephemeral

| Artifact | Committed | Notes |
| --- | --- | --- |
| Specs, schemas, examples, configs | Yes | Source of truth |
| Agents, commands, skills | Yes | Reviewed |
| Run state | No by default | Generated; commit a sample if needed |
| Evidence artifacts | No by default | External store; hash in trace |
| Trace | No by default | External sink; export on request |
| Readiness report | Optional | Commit for an audit snapshot |
| Review, acceptance, release, incident records | Optional | Commit the decision record |

Large artifacts stay external; the hash is the durable reference.

## 9. Anti-patterns

- A YAML file without a schema.
- A schema without an example.
- A committed trace with secrets.
- A generated file that looks editable.
- A file name that encodes a version.
- An `apiVersion` that drifts between documents.
- A schema change with no example update.

## 10. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [cli-contract.md](cli-contract.md) — commands and output
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md) — runtime
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [trace-and-audit.md](../50-observability/trace-and-audit.md) — trace
- [schemas/README.md](../../schemas/README.md) — schema index
- [docs/README.md](../README.md) — documentation map
