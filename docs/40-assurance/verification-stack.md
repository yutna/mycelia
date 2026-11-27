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
- Keep the feedback loop fast; a slow check invites bypass. The tiers in §12
  set where each layer runs.

## 11. Risk matrix

| Risk | Required checks |
| --- | --- |
| R0 | Markdown lint, link check, schema validation when relevant |
| R1 | R0 plus unit tests and review |
| R2 | R1 plus integration tests, changed-line coverage, mutation, security scan |
| R3 | R2 plus end-to-end or performance where relevant, migration dry run, security review, human acceptance |
| R4 | R3 plus rollback drill, provenance attestation, human sign-off |

## 12. Verification tiers

The risk matrix in §11 decides which automated checks a work item needs. The
tiers below decide where those checks run and over what scope, so that a
one-line change does not pay for a full release matrix on every push. Review
and human acceptance follow their own documents.

| Tier | Runs on | Scope |
| --- | --- | --- |
| Fast gate | Every push to a pull request; the merge queue for R0-R2 unless an `MYC-ASR-002` trigger applies | The automated layers the risk matrix requires, over the checks the change affects |
| Full gate | The default branch on a schedule; release branches and release candidates; the merge queue for R3-R4; a pull request when a trigger in `MYC-ASR-002` applies | Every automated layer the risk matrix requires, over the whole repository |
| N-1 compatibility | Release branches and release candidates; a pull request whose work item declares a compatibility risk | Upgrade, adoption, or migration from the previous supported release |

Terms:

- The **selection map** is the recorded mapping from changed paths to the
  checks they affect. It is versioned, and its version is part of the
  evidence, so the selection can be reproduced (§3).
- A **skip rule** is a named rule that lets a layer not run for a change and
  names the evidence that replaces it.
- The **reference runner** is the pinned runner image or container of §10. Gate
  durations are measured from job start on it, not from the push, so queue
  wait is not counted.

Defaults; a repository MAY change them in the `verification` section of
`mycelia.yaml` ([mycelia](../../schemas/mycelia.schema.json)), where it also lists its skip rules:

| Setting | Default |
| --- | --- |
| Fast gate target, job start to verdict on the reference runner | 5 minutes |
| Fast gate overruns before a defect is opened | 3 in 7 days |
| Full gate schedule on the default branch | Nightly |
| Missed or failing scheduled full gates before the ceiling is lowered | 3 in a row |
| Maximum pre-merge full-gate runs per work item | 3 |
| Release branch pattern for N-1 compatibility | `release/*` |

### `MYC-ASR-001` Fast gate

- **Statement:** Every push to a pull request MUST run a fast gate: the
  automated layers the risk matrix (§11) requires for the work item's risk
  tier, over the checks the selection map links to the changed paths. Each
  required layer MUST produce at least one result or a valid skip record
  (`MYC-ASR-005`); when the map selects no check for a required layer, that
  whole layer runs. The fast gate MUST always include static analysis, docs and
  schema checks for changed files, and the guard canaries and meta-check of any
  changed guard ([guard-design.md](../20-control/guard-design.md)
  `MYC-CTL-004`, `MYC-CTL-005`). When the selection map cannot compute a
  selection, the full gate MUST run instead. The runtime MUST record the
  selection map version and the duration; a run over the target MUST still
  finish and MUST NOT be cut short into a pass.
- **Rationale:** A loop that waits 15-20 minutes per pull request runs few
  iterations and invites people and agents to bypass slow checks.
- **Applies to:** L2-L4; all risk tiers. Recommended at L1.
- **Evidence:** Fast gate results with the selection map version, the selected
  checks, and the duration (the `gate` object in [evidence](../../schemas/evidence.schema.json)).
- **Verification:** Fixture `fast-gate`: an empty selection for a required
  layer runs the whole layer, and a selection that cannot be computed runs the
  full gate. Assessor sample of fast gate selections against the selection
  map; overrun metric against the configured target.
- **Failure mode:** The change is `rejected` when a selected check fails;
  repeated overruns past the configured count open a defect with an owner. A
  required layer with neither a result nor a valid skip record blocks the
  change (`MYC-ASR-005`); ceiling lowered to L1 when a gate can pass that way.

### `MYC-ASR-002` Full gate

- **Statement:** The full gate MUST run every automated layer the risk matrix
  requires over the whole repository on the default branch at the configured
  schedule, on release branches and release candidates, and in the merge queue
  for R3 and R4. It MUST also run, once per head commit when the pull request
  is marked ready and in the merge queue, on a pull request that changes the
  build, CI configuration, a lockfile, the toolchain, shared test
  infrastructure, the selection map, or the skip rules. When the full gate
  fails, after the flake check of §4, on a check that the fast gate did not
  select for the same code, the miss MUST be recorded as a selection-map
  defect, and a fixture that reproduces the miss MUST be added and shown to go
  unselected before the map is fixed (the pattern of `MYC-CTL-003`). The merge
  queue computes its selection against the queue base.
- **Rationale:** Affected-only selection is only as good as its map. The full
  gate catches what the map misses and turns each miss into a fixed map.
- **Applies to:** L2-L4; all risk tiers. Recommended at L1.
- **Evidence:** Full gate results with their trigger (`gate.trigger` in
  [evidence](../../schemas/evidence.schema.json)); selection-map defect records with their fixtures
  ([selection-map-defect](../../schemas/selection-map-defect.schema.json)).
- **Verification:** Fixture `selection-map-miss`: a full gate failure on an
  unselected check is recorded as a selection-map defect. Assessor check of the
  schedule and the triggers; audit sample of selection-map defects.
- **Failure mode:** A failing scheduled full gate opens a defect with an owner
  and blocks releases from the default branch until it passes; ceiling lowered
  to L1 after the configured number of missed or failing scheduled full gates
  in a row.

### `MYC-ASR-003` N-1 compatibility on release branches

- **Statement:** Compatibility checks against the previous supported release
  (upgrade, adoption, or migration from N-1) MUST run on release branches and
  release candidates, and on a pull request whose work item declares a
  compatibility risk in its constraints. Other pull requests need not run them
  and MAY run them.
- **Rationale:** N-1 checks take the longest and matter at release time; on
  every pull request they make each change pay for a release.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** N-1 results on each release branch and release candidate.
- **Verification:** Assessor check of release records.
- **Failure mode:** The release is blocked until the N-1 checks pass.

### `MYC-ASR-004` Full-gate run budget

- **Statement:** Each pre-merge full-gate run that the work item's own change
  starts (a trigger in `MYC-ASR-002`, a required R3 or R4 run, or a flake
  re-run of one of these, §4) MUST count against the configured maximum in the
  durable budget ledger (`MYC-EXE-007`). Runs caused by a selection-map
  fallback (`MYC-ASR-001`), by another merge queue entry, or by the schedule or
  a release do not count. A counted run that would exceed the maximum MUST NOT
  start, and the loop run MUST end `aborted` as budget exhaustion
  ([failure-and-ambiguity.md](../30-execution/failure-and-ambiguity.md) §2); a
  human may grant a new budget in a new run.
- **Rationale:** A change that needs many full runs is thrashing or hiding a
  flake; more runs cost time without adding evidence.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Full-gate run counts in the budget ledger
  ([budget-ledger](../../schemas/budget-ledger.schema.json)).
- **Verification:** Fixture `full-gate-budget`: request one run over the
  maximum; it does not start and the loop run ends `aborted`; a merge queue
  rebuild caused by another entry does not count.
- **Failure mode:** The loop run is `aborted` by budget.

### `MYC-ASR-005` Skip rules and replacement evidence

- **Statement:** A layer the risk matrix requires MAY be skipped for a change
  only by a named skip rule that the repository configures, and only at the
  same commit as the rest of the evidence. A skipped layer MUST be recorded as
  `skipped` with the rule name and the replacement evidence, never as `pass`.
  For the gate outcome
  ([evidence-manifest.md](../20-control/evidence-manifest.md) §8), a `skipped`
  record with valid replacement evidence counts as present; without it, the
  layer is missing. Adding or changing a skip rule is a guard loosening
  ([guard-design.md](../20-control/guard-design.md) `MYC-CTL-006`, human
  approval) and MUST NOT apply in the pull request that adds or changes it. A
  skip rule's path globs MUST have look-alike fixtures (`MYC-CTL-002`). These
  MUST NOT be skipped: the secret scan, red-line guard canaries, the test-diff
  guard on a changed test ([test-integrity.md](test-integrity.md) §4), and any
  layer for R3 or R4. A skip is not a quarantine: a quarantined check is a
  time-bound exception and is reported as `blocked` (§4). Carrying evidence
  from an earlier commit follows `MYC-EXE-021`
  ([change-lifecycle.md](../30-execution/change-lifecycle.md) §8); skip records
  are re-evaluated at the new head.
- **Rationale:** Skipping by rule makes the shortcut auditable; skipping by
  judgment makes it a bypass.
- **Applies to:** L2-L4; all risk tiers.
- **Evidence:** Evidence records with the result `skipped`, the rule name, and
  the replacement evidence ([evidence](../../schemas/evidence.schema.json)).
- **Verification:** Fixture `skip-rule`: a skip without replacement evidence
  blocks the change, and a skip rule added in the same pull request does not
  apply. Assessor check of the configured skip rules; audit sample of skip
  records.
- **Failure mode:** The change is `blocked` when a required layer has neither a
  result nor a valid skip record.

Example skip rule: a change whose paths all match the repository's docs globs
skips the unit, integration, and mutation layers, and the docs and schema
checks are its replacement evidence. A look-alike fixture shows that a code
file under a docs-like path is not matched.

## 13. Evidence

Every check records:

- the command
- the exit status
- the commit
- the environment
- the artifact hash
- the verifier
- the trace event

The evidence manifest decides which checks are required for the work item.

## 14. Anti-patterns

- A 100 percent global coverage goal with weak assertions.
- Automatic retries that hide flakes.
- A security scan only at release time.
- A performance test on a noisy shared runner with no threshold.
- A manual test with no evidence.
- Local commands that differ from CI.
- Skipping docs and schema checks because "they are not code".
- A gate that passes when a check is missing.

## 15. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [principles.md](../00-foundations/principles.md) — design principles
- [autonomy-levels.md](../00-foundations/autonomy-levels.md) — risk tiers
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [autonomous-loop.md](../30-execution/autonomous-loop.md) — loop
- [test-integrity.md](test-integrity.md) — mutation and test weakening
- [review-rubric.md](review-rubric.md) — review
- [guard-design.md](../20-control/guard-design.md) — guards and canaries
- [docs/README.md](../README.md) — documentation map
