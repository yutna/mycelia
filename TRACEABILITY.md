# Traceability matrix

Status: Draft (v1.0.0)

## 1. Purpose

The freeze needs a single matrix that proves every requirement is owned,
evidenced, and assessed. This document maps core requirements to specification
sections, evidence, and controls; controls to documents; and schemas to
examples.

## 2. Core requirements

| Requirement | Specification | Evidence | Control |
| --- | --- | --- | --- |
| `MYC-CORE-001` | [SPEC.md](SPEC.md) §10 | Work item | `CTL-02` |
| `MYC-CORE-002` | [SPEC.md](SPEC.md) §10 | Role contract | `CTL-07` |
| `MYC-CORE-003` | [SPEC.md](SPEC.md) §10 | Policy decision | `CTL-08` |
| `MYC-CORE-004` | [SPEC.md](SPEC.md) §10 | Run state | `CTL-13` |
| `MYC-CORE-005` | [SPEC.md](SPEC.md) §10 | Evidence manifest | `CTL-11` |
| `MYC-CORE-006` | [SPEC.md](SPEC.md) §10 | Review and acceptance | `CTL-21`, `CTL-22` |
| `MYC-CORE-007` | [SPEC.md](SPEC.md) §10 | Trace event | `CTL-23` |
| `MYC-CORE-008` | [SPEC.md](SPEC.md) §10 | Blocked state | `CTL-14` |
| `MYC-CORE-009` | [SPEC.md](SPEC.md) §10 | Gate result | `CTL-17` |
| `MYC-CORE-010` | [SPEC.md](SPEC.md) §10 | Readiness report | `CTL-24` |
| `MYC-CORE-011` | [SPEC.md](SPEC.md) §10 | Exception record | `CTL-12` |
| `MYC-CORE-012` | [SPEC.md](SPEC.md) §10 | Variance note | `CTL-23` |

## 3. Assessment controls

| Control | Owning document | Evidence |
| --- | --- | --- |
| `CTL-01` | [repository-legibility.md](docs/10-context/repository-legibility.md) | Clean-clone check |
| `CTL-02` | [work-intake.md](docs/10-context/work-intake.md) | Work item schema |
| `CTL-03` | [repository-legibility.md](docs/10-context/repository-legibility.md) | Ownership record |
| `CTL-04` | [AGENTS.md](AGENTS.md), [CONTRIBUTING.md](CONTRIBUTING.md) | Instruction files |
| `CTL-05` | [context-engineering.md](docs/10-context/context-engineering.md) | Pinned references |
| `CTL-06` | [context-engineering.md](docs/10-context/context-engineering.md) | Compaction policy |
| `CTL-07` | [roles-and-permissions.md](docs/20-control/roles-and-permissions.md) | Role contracts |
| `CTL-08` | [policy-as-code.md](docs/20-control/policy-as-code.md) | Negative tests |
| `CTL-09` | [roles-and-permissions.md](docs/20-control/roles-and-permissions.md) | Bot identity and secret policy |
| `CTL-10` | [policy-as-code.md](docs/20-control/policy-as-code.md) | Policy file and tests |
| `CTL-11` | [evidence-manifest.md](docs/20-control/evidence-manifest.md) | Manifest and gate |
| `CTL-12` | [decision-rights.md](docs/20-control/decision-rights.md) | Decision records |
| `CTL-13` | [autonomous-loop.md](docs/30-execution/autonomous-loop.md) | Run state and resume test |
| `CTL-14` | [failure-and-ambiguity.md](docs/30-execution/failure-and-ambiguity.md) | Taxonomy and drill |
| `CTL-15` | [budgets-and-kill-switch.md](docs/20-control/budgets-and-kill-switch.md) | Limits and drill |
| `CTL-16` | [multi-agent-concurrency.md](docs/30-execution/multi-agent-concurrency.md) | Worktree record |
| `CTL-17` | [multi-agent-concurrency.md](docs/30-execution/multi-agent-concurrency.md) | Merge queue result |
| `CTL-18` | [release-and-rollback.md](docs/40-assurance/release-and-rollback.md) | Rollback drill |
| `CTL-19` | [verification-stack.md](docs/40-assurance/verification-stack.md) | CI jobs |
| `CTL-20` | [test-integrity.md](docs/40-assurance/test-integrity.md) | Mutation report |
| `CTL-21` | [review-rubric.md](docs/40-assurance/review-rubric.md) | Review record |
| `CTL-22` | [human-acceptance.md](docs/40-assurance/human-acceptance.md) | Acceptance record |
| `CTL-23` | [trace-and-audit.md](docs/50-observability/trace-and-audit.md), [provenance.md](docs/50-observability/provenance.md) | Trace and provenance |
| `CTL-24` | [metrics-and-health.md](docs/50-observability/metrics-and-health.md), [evaluation-and-model-change.md](docs/60-evolution/evaluation-and-model-change.md) | Metrics and evaluation |

## 4. Schemas

| Schema | Owning document | Example |
| --- | --- | --- |
| `work-item` | [work-intake.md](docs/10-context/work-intake.md) | [example](examples/work-item.example.yaml) |
| `role-contract` | [roles-and-permissions.md](docs/20-control/roles-and-permissions.md) | [example](examples/role-contract.example.yaml) |
| `policy-decision` | [policy-as-code.md](docs/20-control/policy-as-code.md) | [example](examples/policy-decision.example.yaml) |
| `evidence-manifest` | [evidence-manifest.md](docs/20-control/evidence-manifest.md) | [example](examples/evidence-manifest.example.yaml) |
| `evidence` | [evidence-manifest.md](docs/20-control/evidence-manifest.md) | [example](examples/evidence.example.yaml) |
| `run-state` | [autonomous-loop.md](docs/30-execution/autonomous-loop.md) | [example](examples/run-state.example.yaml) |
| `handoff` | [multi-agent-concurrency.md](docs/30-execution/multi-agent-concurrency.md) | [example](examples/handoff.example.yaml) |
| `test-integrity-report` | [test-integrity.md](docs/40-assurance/test-integrity.md) | [example](examples/test-integrity-report.example.yaml) |
| `review-record` | [review-rubric.md](docs/40-assurance/review-rubric.md) | [example](examples/review-record.example.yaml) |
| `acceptance-record` | [human-acceptance.md](docs/40-assurance/human-acceptance.md) | [example](examples/acceptance-record.example.yaml) |
| `release-record` | [release-and-rollback.md](docs/40-assurance/release-and-rollback.md) | [example](examples/release-record.example.yaml) |
| `trace-event` | [trace-and-audit.md](docs/50-observability/trace-and-audit.md) | [example](examples/trace-event.example.yaml) |
| `provenance-record` | [provenance.md](docs/50-observability/provenance.md) | [example](examples/provenance-record.example.yaml) |
| `evaluation-record` | [evaluation-and-model-change.md](docs/60-evolution/evaluation-and-model-change.md) | [example](examples/evaluation-record.example.yaml) |
| `incident-record` | [incident-response.md](docs/60-evolution/incident-response.md) | [example](examples/incident-record.example.yaml) |
| `mycelia` | [template-and-adoption.md](docs/60-evolution/template-and-adoption.md) | [example](examples/mycelia.example.yaml) |
| `readiness-report` | [readiness-assessment.md](docs/70-adoption/readiness-assessment.md) | [example](examples/readiness-report.example.yaml) |

## 5. Coverage

The 12 original areas, the Tier 1 and Tier 2 keywords, and the external
frameworks are mapped in
[coverage-crosswalk.md](docs/70-adoption/coverage-crosswalk.md). The claims and
evidence are in [assurance-case.md](docs/70-adoption/assurance-case.md).

## 6. Maintenance

- Add a row when a requirement, control, or schema is added.
- Remove a row only when the item is retired with a recorded decision.
- Revalidate the matrix before each release.
- The matrix is part of the release evidence.

## 7. Related documents

- [README.md](README.md) — project identity and map
- [SCOPE.md](SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](SPEC.md) — normative core
- [AUDIT.md](AUDIT.md) — audit findings
- [coverage-crosswalk.md](docs/70-adoption/coverage-crosswalk.md) — coverage
- [assurance-case.md](docs/70-adoption/assurance-case.md) — claims
- [docs/README.md](docs/README.md) — documentation map
