# Evidence manifest

Status: Draft

## 1. Purpose

The evidence manifest is the machine-readable definition of done. The work item
says what to do; the manifest says what proves it. A gate evaluates the
manifest and either passes, fails, blocks, or records an explicit waiver.

## 2. Work item versus manifest

| Artifact | Question | Owner |
| --- | --- | --- |
| Work item | What are we doing, and what is out of scope? | Planner and human owner |
| Evidence manifest | What proves it is done? | Maintainer and verifier |
| Evidence | Did this run satisfy the manifest? | Producer and verifier |

The work item references the manifest. The manifest does not restate the goal;
it defines the proof.

## 3. Evidence types

| Type | Examples | Typical risk |
| --- | --- | --- |
| `lint` | Markdownlint, actionlint, language linter | R0-R4 |
| `link-check` | Internal links and anchors | R0 |
| `schema-validation` | JSON Schema and config validation | R0-R4 |
| `unit-test` | Fast isolated tests | R1-R4 |
| `integration-test` | Tests across components | R2-R4 |
| `e2e-test` | User-level flow | R2-R4 |
| `coverage` | Changed-line coverage | R2-R4 |
| `mutation` | Mutation score on changed lines | R2-R4 |
| `property-based` | Invariants over generated inputs | R2-R4 |
| `static-analysis` | Type check, SAST, complexity | R1-R4 |
| `dependency-scan` | Known vulnerabilities, licenses | R1-R4 |
| `secret-scan` | Leaked credentials | R0-R4 |
| `performance` | Latency, throughput, budget | R2-R4 |
| `migration-dry-run` | Schema or data migration rehearsal | R3-R4 |
| `rollback-drill` | Tested rollback | R3-R4 |
| `review` | Independent review record | R1-R4 |
| `security-review` | Security sign-off | R3-R4 |
| `human-signoff` | Human acceptance | R3-R4 |
| `provenance-attestation` | Build and artifact provenance | R3-R4 |
| `trace-export` | Correlated trace artifact | R0-R4 |

## 4. Manifest fields

| Field | Required | Meaning |
| --- | --- | --- |
| `id` | Yes | Stable manifest identifier |
| `version` | Yes | Semantic version of the manifest |
| `appliesTo` | Yes | Risk tiers the manifest covers |
| `requirements` | Yes | The evidence requirements |
| `gates` | Yes | Which requirements gate merge, release, or promotion |

A requirement has:

| Field | Required | Meaning |
| --- | --- | --- |
| `id` | Yes | Stable requirement identifier |
| `description` | Yes | What must be proven |
| `evidenceType` | Yes | One of the evidence types |
| `producer` | Yes | Role that produces the evidence |
| `verifier` | Yes | Role that verifies it |
| `threshold` | No | Numeric or textual threshold |
| `freshness` | No | How recent the evidence must be |
| `required` | Yes | Whether the gate fails when it is missing |
| `gate` | No | `merge`, `release`, or `promotion` |

## 5. Evidence record

Every produced evidence item has:

| Field | Meaning |
| --- | --- |
| `manifestID` | The manifest it satisfies |
| `requirementID` | The requirement it satisfies |
| `type` | The evidence type |
| `producer` | Role that produced it |
| `verifier` | Role that verified it |
| `commit` | The commit the evidence belongs to |
| `command` | The exact command, when applicable |
| `environment` | Toolchain, OS, and dependency lock |
| `timestamp` | When it was produced |
| `hash` | SHA-256 of the artifact |
| `location` | Where the artifact is stored |
| `result` | `pass`, `fail`, or `blocked` |
| `verifiedAt` | When the verifier checked it |
| `traceEvent` | The trace event that links the evidence to the run |

## 6. Gate model

A gate is a named set of requirements:

| Gate | When it runs | Typical requirements |
| --- | --- | --- |
| `merge` | Before a change reaches `main` | Lint, tests, coverage, review |
| `release` | Before a tag or release | Merge gate plus integration, security, provenance |
| `promotion` | Before raising the autonomy level | Release gate plus readiness, evaluations, incident drills |

A gate evaluates the manifest against the evidence for the current commit.

## 7. Verification rules

1. The producer and the verifier are different actors for R2 and above.
2. The evidence commit matches the change commit.
3. The evidence is fresh within its declared window.
4. The evidence is reproducible: command, environment, and lockfile.
5. The evidence is tamper-evident: hash, trace event, append-only store.
6. An agent cannot verify its own evidence.
7. Missing, stale, failed, or unverifiable evidence is a failure.
8. A waiver is a time-bound exception, recorded, and never counted as a pass.
9. The gate re-runs the evidence in CI where the check is automatable.
10. Evidence from another commit or another work item is invalid.

## 8. Gate outcomes

| Outcome | Meaning | Effect |
| --- | --- | --- |
| `pass` | Every required evidence is present, fresh, and verified | The transition may proceed |
| `fail` | Any required evidence failed or is invalid | The transition is rejected |
| `blocked` | Evidence or a verifier is missing | The work item is blocked |
| `waived` | A human granted a time-bound exception | The transition may proceed with the exception recorded |

There is no implicit pass. An empty gate is a configuration error.

## 9. Storage and retention

- Store artifacts in CI or an artifact store; store the hash and location in
  the trace.
- The hash is authoritative; a link can rot, the hash cannot.
- Redact secrets and personal data before storage.
- Retain security and release evidence longer than transient logs.
- Expire evidence according to its freshness window.
- The trace records the evidence event even when the artifact is external.

## 10. Example

An R2 manifest requires:

- lint and link check
- unit and integration tests
- changed-line coverage at or above the threshold
- mutation score at or above the threshold
- schema validation when a data contract changed
- independent review

The merge gate requires all of them. A missing review is `blocked`, not
`pass`.

## 11. Anti-patterns

- "Tests pass" with no command, log, or commit.
- A producer marking its own evidence as verified.
- Evidence from a different commit.
- A gate that passes when a requirement is missing.
- A waiver without an owner or an expiry.
- A hash that is not checked.
- A secret stored in an evidence artifact.
- A manifest that never changes while the project does.

## 12. Data contract

- Manifest schema: [schemas/evidence-manifest.schema.json](../../schemas/evidence-manifest.schema.json)
- Evidence schema: [schemas/evidence.schema.json](../../schemas/evidence.schema.json)
- Manifest example: [examples/evidence-manifest.example.yaml](../../examples/evidence-manifest.example.yaml)
- Evidence example: [examples/evidence.example.yaml](../../examples/evidence.example.yaml)

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [threat-model.md](../00-foundations/threat-model.md) — threats and controls
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — levels and tiers
- [work-intake.md](../10-context/work-intake.md) — work item contract
- [roles-and-permissions.md](roles-and-permissions.md) — role catalog
- [policy-as-code.md](policy-as-code.md) — policy model
- `verification-stack.md` — checks (planned)
- `test-integrity.md` — mutation and test weakening (planned)
- [docs/README.md](../README.md) — documentation map
