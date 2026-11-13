# Verification stack

Status: Draft

## 1. Purpose

Evidence is only as good as the checks behind it. This document defines the
layers of verification, the determinism required to trust them, the flake
policy, and the checks required at each risk tier.

## 2. Layers

| Layer | Purpose | Example command | Evidence |
| --- | --- | --- | --- |
| Static analysis | Catch type, lint, and policy errors | `npm run lint`, `tsc --noEmit` | Lint log |
| Unit | Verify one unit in isolation | `npm test -- unit` | Test log |
| Integration | Verify components together | `npm test -- integration` | Test log |
| End-to-end | Verify a user flow | `npm run test:e2e` | Test log, trace |
| Property-based | Verify invariants over generated inputs | `npm test -- property` | Test log |
| Mutation | Verify the tests can fail | `npm run test:mutation` | Mutation score |
| Security | Find vulnerabilities and secrets | SAST, dependency scan, secret scan | Scan report |
| Performance | Verify a budget | `npm run bench` | Benchmark result |
| Migration | Rehearse a schema or data change | `npm run migrate -- --dry-run` | Dry-run log |
| Docs | Verify links and Markdown | `mise run lint` | Lint log |
| Schema | Verify data contracts | `mise run lint:schemas` | Validation log |

## 3. Determinism

A check is trustworthy only when it is reproducible:

- Pin the toolchain with mise and commit the lockfile.
- Pin dependencies.
- Fix the timezone, locale, and clock where the test depends on them.
- Seed random generators; record the seed.
- Do not call a live external service in a unit test.
- Use ephemeral services for integration tests.
- Use fixtures and factories, not shared mutable state.
- Isolate tests from each other.
- Run the same command locally and in CI.

A check that depends on the developer's machine is not evidence.

## 4. Flake policy

A flaky check is a defect, not a nuisance.

- Detect flakiness by re-running the check and comparing results.
- Quarantine the check with an owner and an expiry date.
- Do not hide flakiness behind automatic retries.
- A quarantined check is reported as `blocked`, not `pass`.
- Fix or replace the check before the expiry.
- Track the flake rate as a metric.
- A high flake rate lowers the repository's autonomy ceiling.

## 5. Coverage and mutation

- Gate on changed-line coverage, not global coverage.
- Use global coverage as a trend, not a gate.
- Set a mutation score threshold for the changed code.
- Prefer a meaningful assertion over a line hit.
- Treat coverage as a signal, not a goal.
- Record the threshold in the evidence manifest.

A green coverage number with weak assertions is a false signal.

## 6. Security checks

- Static application security testing (SAST).
- Dependency vulnerability scan.
- Secret scan.
- License scan.
- Container or base image scan when the project ships one.
- Security review for R3 and R4.

Thresholds:

- No critical or high findings on the changed code.
- A medium finding needs an owner and a time-bound exception.
- A secret finding stops the run and triggers an incident.

## 7. Performance

- Define a budget per critical operation.
- Benchmark on stable hardware or a dedicated runner.
- Compare against the baseline, not an absolute number in isolation.
- Account for noise; require a meaningful regression.
- Record the budget and the result in the evidence.
- A failed performance budget is a failure, not a warning.

## 8. Migration and data

- Run a dry run before a schema or data migration.
- Record the planned change and the rollback.
- Test the rollback on a copy.
- Never run a destructive migration without a backup and a human approval.
- R3 and R4 migrations require a rollback drill.

## 9. Docs and schema

- Markdown lint and link check.
- Schema meta-validation.
- Example validation against the schema.
- Generated documentation freshness, if the project has it.
- A broken internal link is a failure, not a warning.

## 10. CI execution and parity

- Put each layer in its own job or step.
- `ci-ok` needs every job and fails on a failure or cancellation.
- Upload artifacts and record their hashes.
- Cache dependencies, not test results.
- Keep local commands and CI commands the same.
- Pin the runner image or container.
- Keep the feedback loop fast; a slow check invites bypass.

## 11. Risk matrix

| Risk | Required checks |
| --- | --- |
| R0 | Markdown lint, link check, schema validation when relevant |
| R1 | R0 plus unit tests and review |
| R2 | R1 plus integration tests, changed-line coverage, mutation, security scan |
| R3 | R2 plus end-to-end or performance where relevant, migration dry run, security review, human acceptance |
| R4 | R3 plus rollback drill, provenance attestation, human sign-off |

## 12. Evidence

Every check records:

- the command
- the exit status
- the commit
- the environment
- the artifact hash
- the verifier
- the trace event

The evidence manifest decides which checks are required for the work item.

## 13. Anti-patterns

- A 100 percent global coverage goal with weak assertions.
- Automatic retries that hide flakes.
- A security scan only at release time.
- A performance test on a noisy shared runner with no threshold.
- A manual test with no evidence.
- Local commands that differ from CI.
- Skipping docs and schema checks because "they are not code".
- A gate that passes when a check is missing.

## 14. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — risk tiers
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [autonomous-loop.md](../30-execution/autonomous-loop.md) — loop
- `test-integrity.md` — mutation and test weakening (planned)
- `review-rubric.md` — review (planned)
- [docs/README.md](../README.md) — documentation map
