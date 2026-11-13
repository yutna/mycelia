# Schemas

The data contracts for Mycelia. Each schema is JSON Schema 2020-12 and has a
validated example.

## Index

| Schema | Kind | Example |
| --- | --- | --- |
| [work-item](work-item.schema.json) | `WorkItem` | [work-item](../examples/work-item.example.yaml) |
| [role-contract](role-contract.schema.json) | `RoleContract` | [role-contract](../examples/role-contract.example.yaml) |
| [policy-decision](policy-decision.schema.json) | `PolicyDecision` | [policy-decision](../examples/policy-decision.example.yaml) |
| [evidence-manifest](evidence-manifest.schema.json) | `EvidenceManifest` | [evidence-manifest](../examples/evidence-manifest.example.yaml) |
| [evidence](evidence.schema.json) | `Evidence` | [evidence](../examples/evidence.example.yaml) |
| [run-state](run-state.schema.json) | `RunState` | [run-state](../examples/run-state.example.yaml) |
| [handoff](handoff.schema.json) | `Handoff` | [handoff](../examples/handoff.example.yaml) |
| [test-integrity-report](test-integrity-report.schema.json) | `TestIntegrityReport` | [test-integrity-report](../examples/test-integrity-report.example.yaml) |
| [review-record](review-record.schema.json) | `ReviewRecord` | [review-record](../examples/review-record.example.yaml) |
| [acceptance-record](acceptance-record.schema.json) | `AcceptanceRecord` | [acceptance-record](../examples/acceptance-record.example.yaml) |
| [release-record](release-record.schema.json) | `ReleaseRecord` | [release-record](../examples/release-record.example.yaml) |
| [trace-event](trace-event.schema.json) | `TraceEvent` | [trace-event](../examples/trace-event.example.yaml) |
| [provenance-record](provenance-record.schema.json) | `ProvenanceRecord` | [provenance-record](../examples/provenance-record.example.yaml) |
| [evaluation-record](evaluation-record.schema.json) | `EvaluationRecord` | [evaluation-record](../examples/evaluation-record.example.yaml) |
| [incident-record](incident-record.schema.json) | `IncidentRecord` | [incident-record](../examples/incident-record.example.yaml) |
| [mycelia](mycelia.schema.json) | `MyceliaConfig` | [mycelia](../examples/mycelia.example.yaml) |
| [readiness-report](readiness-report.schema.json) | `ReadinessReport` | [readiness-report](../examples/readiness-report.example.yaml) |

## Validate

```sh
mise run lint:schemas
```

The task validates every schema against the 2020-12 meta-schema and every
example against its schema.

## Conventions

- `$schema` is the 2020-12 meta-schema.
- `$id` is stable and repository-relative.
- `additionalProperties` is `false` unless an extension point is deliberate.
- Every schema requires `apiVersion`, `kind`, `metadata`, and `spec`.
- `apiVersion` is `mycelia/v1`.
- Every example validates against its schema.
- A new schema updates the index, `mise.toml`, the CI job, and the
  traceability matrix.

## Related

- [File formats](../docs/80-interface/file-formats.md)
- [Specification](../SPEC.md)
- [Glossary](../GLOSSARY.md)
